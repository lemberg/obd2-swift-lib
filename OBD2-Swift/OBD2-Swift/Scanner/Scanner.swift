//
//  Sanner.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum ReadInputError: Error {
    case initResponseUnreadable
}

enum InitScannerError: Error {
    case outputTimeout
    case inputTimeout
}

class `Scanner`: StreamHolder {
  let timeout	=	10.0
  
  var defaultSensors: [UInt8] = [0x0C, 0x0D]
  //weak var delegate : ScanToolDelegate?
  
  var supportedSensorList = [Int]()
  open var sensorScanTargets = [UInt8]()
  
  var initState: ELM327InitState = .UNKNOWN
  var currentSensorIndex = 0
  var streamOperation: Operation!
  var scanOperationQueue: OperationQueue!

  var priorityCommandQueue: [Command] = []
  var commandQueue: [Command] = []

  var state: ScanState = .init
  var `protocol`: ScanProtocol = .none
  var waitingForVoltageCommand = false
  var currentPIDGroup: UInt8 = 0x00

  var maxSize = 512
  var readBuf = [UInt8]()
  var readBufLength = 0
  
  weak var observer: SensorObserver?
  
  var connector: Connector?
  
  init(host: String, port: Int) {
    super.init()
    self.host = host
    self.port = port
    
    delegate = self
  }
  
  open func setupProtocol(buffer: [UInt8]) -> ScanProtocol {
    let asciistr: [Int8] = buffer.map({Int8.init(bitPattern: $0)})
    let respString = String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
    
    var searchIndex = 0
    if Parser.string.isAuto(respString) {
      // The 'A' is for Automatic.  The actual
      // protocol number is at location 1, so
      // increment pointer by 1
      //asciistr += 1
      searchIndex += 1
    }
    
    let uintIndex =  asciistr[searchIndex] - 0x4E
    let index = Int(uintIndex)

    self.`protocol` = elmProtocolMap[index]
    return self.`protocol`
  }
  
  open func request(command: Command, with block: (_ buffer : [UInt8])->()) {
    //TODO:-
  }
  
  open func request(command: Command) {
    
    let request = CommandOperation(inputStream: inputStream, outputStream: outputStream, command: command)
    
    request.onReceiveResponse = { (response) in
        print("Receive response \(response)")
    }
    
    request.completionBlock = {
        print("Request operation completed")
    }
    obdQueue.addOperation(request)
//    eraseBuffer()
//    
//    cachedWriteData.removeAll()
//    
//    guard let data = command.getData() else {
//      //TODO:-failed
//      return
//    }
//    cachedWriteData.append(data)
//    writeCachedData()
  }
  
  open func setSensorScanTargets(targets : [UInt8]){
    sensorScanTargets.removeAll()
    sensorScanTargets = targets
    
    guard let cmd = dequeueCommand() else {return}
    request(command: cmd)
    writeCachedData()
  }
  
  open func isScanning() -> Bool {
    return streamOperation?.isCancelled ?? false
  }
  
  open func startScan(){
    priorityCommandQueue.removeAll()
    commandQueue.removeAll()
    supportedSensorList.removeAll()
    sensorScanTargets.removeAll()
    
    state = .init
    
    open()
    
    let op = InitScanerOperation(inputStream: inputStream, outputStream: outputStream)
    
    op.completionBlock = {
        print("Initialization complete")
    }
    
    state = .init
    initState = .RESET
    currentPIDGroup = 0x00

    obdQueue.addOperation(op)
//    let operation = BlockOperation {
//        self.initScanner()
//    }
    
//    operation.completionBlock = {
//        print("Init scaner operation end")
//    }
//    
//    obdQueue.addOperation(operation)
//    scanOperationQueue = OperationQueue()
//    streamOperation = BlockOperation(block: { [weak self] in
//      self?.runStreams()
//    })
    
//    scanOperationQueue.addOperation(streamOperation)
//    scanOperationQueue.isSuspended = false
  }
  
  open func pauseScan(){
    scanOperationQueue.isSuspended = true
  }
  
  open func resumeScan(){
    scanOperationQueue.isSuspended = false
  }
  
  open func cancelScan(){
    scanOperationQueue.cancelAllOperations()
    streamOperation.cancel()
    supportedSensorList.removeAll()
  }
  
  open func isService01PIDSupported(pid : Int) -> Bool {
    var supported = false
    
    for supportedPID in supportedSensorList {
      if supportedPID == pid {
        supported = true
        break
      }
    }
    
    return supported
  }
  
  func setupReady(){
    state = .idle
    setSensorScanTargets(targets: [])
  }
  
  func readInput() {
    var buffer = [UInt8].init(repeating: 0, count: maxSize)
    let readLength = inputStream.read(&buffer, maxLength: maxSize)
    
    guard readLength > 0 else {
        //TODO: no input response
        return
    }
    
    buffer.removeSubrange(readLength..<maxSize)
    
    readBuf += buffer
    readBufLength += readLength
    
    if ELM_READ_COMPLETE(readBuf) {
      if (readBufLength - 3) > 0 && (readBufLength - 3) < readBuf.count {
        readBuf[(readBufLength - 3)] = 0x00
        readBufLength	-= 3
      }
      
      let asciistr : [Int8] = readBuf.map({Int8.init(bitPattern: $0)})
      let respString = String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
      print(respString)
      
      if ELM_ERROR(respString) {
        initState	= .RESET
        state       = .init
      } else {
        let package = Package(buffer: readBuf, length: readBufLength)
        let responses = Parser.package.read(package: package)
        
        self.didReceiveResponses(response: responses)
        
        state = .idle
        
        if let cmd = dequeueCommand() {
          request(command: cmd)
        }
      }
    } else {
      state = .waiting
    }
    
    if state == .idle || state == .init {
      eraseBuffer()
    }
    
  }
  
  func readInitResponse() throws {
    var buffer = [UInt8].init(repeating: 0, count: maxSize)
    let readLength = inputStream.read(&buffer, maxLength: maxSize)
    
    guard readLength > 0 else {
        throw ReadInputError.initResponseUnreadable
    }
    buffer.removeSubrange(readLength..<maxSize)
    
    readBuf += buffer
    readBufLength += readLength
    
    if ELM_READ_COMPLETE(readBuf) {
      if (readBufLength - 3) > 0 && (readBufLength - 3) < readBuf.count {
        readBuf[(readBufLength - 3)] = 0x00
        readBufLength	-= 3
      }
      
      connector?.setup(using: readBuf)
    }
  }
  
  private func initScanner() throws {
    eraseBuffer()
    
    state = .init
    initState = .RESET
    currentPIDGroup = 0x00
    
    var openingStatus = false
    
    let startDate = Date()
    while !openingStatus && Date().timeIntervalSince(startDate) < 5.0 {
        openingStatus = inputStream.streamStatus == Stream.Status.open && outputStream.streamStatus == Stream.Status.open
    }
    
    guard openingStatus else {
        if inputStream.streamStatus == Stream.Status.open {
            throw InitScannerError.outputTimeout
        } else {
            throw InitScannerError.inputTimeout
        }
    }
    
    request(command: Command.reset)
    
    connector?.state = Connector.State.reset
  }
  
  private func enqueueCommand(command: Command) {
    priorityCommandQueue.append(command)
  }
  
  private func clearCommandQueue(){
    priorityCommandQueue.removeAll()
  }
  
  private func dequeueCommand() -> Command? {
    var cmd: Command?
    
    if priorityCommandQueue.count > 0 {
      cmd = priorityCommandQueue.remove(at: 0)
    }else if sensorScanTargets.count > 0 {
      cmd = commandForNextSensor()
    }
    
    return cmd
  }
  
  private func commandForNextSensor() -> Command? {
    if currentSensorIndex >= sensorScanTargets.count {
      currentSensorIndex = 0
      
      // Put a pending DTC request in the priority queue, to be executed
      // after the battery voltage reading
      
      waitingForVoltageCommand = true
      return Command.voltage
    }
    
    let next = self.nextSensor()
    
    if next <= 0x4E {
      return Command.create(mode: .RequestCurrentPowertrainDiagnosticData, pid: next)
    }else {
      return nil
    }
  }
  
  private func nextSensor() -> UInt8 {
    if currentSensorIndex > sensorScanTargets.count {
      currentSensorIndex = 0
    }
    
    let number = sensorScanTargets[currentSensorIndex]
    currentSensorIndex += 1
    
    return number
  }
  
  //MARK: - Scanning Operation
  
  private func runStreams(){
    let currentRunLoop	= RunLoop.current
    let distantFutureDate	= Date.distantFuture
    
    open()
    //delegate?.scanDidStart(scanTool: self)
    
    //TODO: Error cases
    do {
       try initScanner()
    } catch InitScannerError.inputTimeout {
        print("Error: Input stream opening error.")
    } catch InitScannerError.outputTimeout {
        print("Error: Output stream opening error. ")
    } catch {
        print("Error: Unrecognized streams opening error")
    }
    
    while streamOperation?.isCancelled == false && currentRunLoop.run(mode: .defaultRunLoopMode, before: distantFutureDate) {/*loop */}
    
    close()
    //delegate?.scanDidCancel(scanTool: self)
    
  }
  
  
//  func getTroubleCodes(){
//    let cmd = commandForGenericOBD(mode: .RequestEmissionRelatedDiagnosticTroubleCodes, pid: 0, data: nil)
//    enqueueCommand(command: cmd)
//  }
//  
//  func getPendingTroubleCodes(){
//    let cmd = commandForGenericOBD(mode: .RequestEmissionRelatedDiagnosticTroubleCodesDetected, pid: 0, data: nil)
//    enqueueCommand(command: cmd)
//  }
//  
//  func clearTroubleCodes(){
//    let cmd1 = commandForGenericOBD(mode: .ClearResetEmissionRelatedDiagnosticInfo , pid: 0, data: nil)
//    enqueueCommand(command: cmd1)
//    //send Mode 0x01 Pid 0x01 cmd after clear to update sensor trouble code count
//    let cmd2 = commandForGenericOBD(mode: .RequestCurrentPowertrainDiagnosticData  , pid: 0x01, data: nil)
//    enqueueCommand(command: cmd2)
//  }
//  
//  func getBatteryVoltage(){
//    enqueueCommand(command: self.commandForGetBatteryVoltage())
//  }
  
  
  private func didReceiveResponses(response: Response) {
    //INPORTANT = mode to int value == mode ^ 0x40 !!!!!!!!!
    
//    guard responses.count > 0 else {
//      didReceiveNoDATA()
//      return
//    }
//
    
    switch response.mode {
    case Mode.CurrentData01.rawValue:
      break
    case Mode.FreezeFrame02.rawValue:
      break
    case Mode.DiagnosticTroubleCodes03.rawValue:
      break
//    case Mode.RequestCurrentPowertrainDiagnosticData.rawValue:
//      break
//    case Mode.RequestCurrentPowertrainDiagnosticData.rawValue:
//      break
//    case Mode.RequestCurrentPowertrainDiagnosticData.rawValue:
//      break
//    case Mode.RequestCurrentPowertrainDiagnosticData.rawValue:
//      break
//    case Mode.RequestCurrentPowertrainDiagnosticData.rawValue:
//      break
//    case Mode.RequestCurrentPowertrainDiagnosticData.rawValue:
//      break
//    case Mode.RequestCurrentPowertrainDiagnosticData.rawValue:
//      break
    default: //TODO: default realisation
      break
    }
//    let isMode01 = response.mode == ScanToolMode.RequestCurrentPowertrainDiagnosticData.rawValue
//    let isMode02 = response.mode == ScanToolMode.RequestPowertrainFreezeFrameData.rawValue
//    let isMode04 = response.mode == ScanToolMode.ClearResetEmissionRelatedDiagnosticInfo.rawValue
//    
//    if isMode01 || isMode02 {
//      if let sensor = ECUSensor.sensorForPID(pid: response.pid) {
//        sensor.currentResponse = response
//        delegate?.didUpdateSensor(sensor: sensor)
//      }else{
//        delegate?.didReceiveResponse(scanTool: self, responses: responses)
//      }
//    }else if isMode04 {
//      didClearTroubleCodes(response: response)
//    }else if(response.mode == ScanToolMode.RequestVehicleInfo.rawValue){ // MODE 9
//      didUpdate9Mode(response: response)
//    }else if(response.mode == ScanToolMode.RequestEmissionRelatedDiagnosticTroubleCodes.rawValue){ // MODE 3
//      didUpdate3Mode(response : response)
//    }else if(response.mode == 64){ // AT Commands
//      didUpdateATCommand(response: response)
//    }
  }
  
  fileprivate func readVoltageResponse()  {
    let readLength = inputStream.read(&readBuf, maxLength: readBufLength)

    guard readLength > 0 else {
        //TODO: no input response
        return
    }
    
    var buff = readBuf
    buff.removeSubrange(readLength..<maxSize)
    
    readBufLength = readLength
    
    if ELM_READ_COMPLETE(buff) {
      state			= .processing
      
      if (readBufLength - 3) > 0 && (readBufLength - 3) < buff.count {
        buff[(readBufLength - 3)] = 0x00
        readBufLength	-= 3
      }
      
      let asciistr : [Int8] = buff.map({Int8.init(bitPattern: $0)})
      let respString = String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
      print(respString)
      
      if ELM_ERROR(respString) {
        initState	= .RESET
        state       = .init
      } else {
        //delegate?.didReceiveVoltage(scanTool: self, voltage: respString)
        state       = .idle
        
        if let cmd = dequeueCommand() {
          request(command: cmd)
        }
      }
    } else {
      state = .waiting
    }
    
    if state == .idle || state == .init {
      eraseBuffer()
      waitingForVoltageCommand	= false
    }
  }

  private func eraseBuffer(){
    readBufLength = 0
    readBuf.removeAll()
  }
}

extension Scanner: StreamFlowDelegate {
  func didOpen(stream: Stream){
    
  }
  
  func error(_ error: Error, on stream: Stream){
    
  }
  
  func hasInput(on stream: Stream){
    
    do {
    
        if state == .init {
          try readInitResponse()
        } else if state == .idle || state == .waiting {
            waitingForVoltageCommand ? readVoltageResponse() : readInput()

        } else {
          print("Error: Received bytes in unknown state: \(state)")
        }
        
    } catch {
        
        print("Error: Init response unreadable. Need reconnect")
        //TODO: try reconnect    
    }
    
    
  }
}
