//
//  ScanTool.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation
import CoreLocation

let VOLTAGE_TIMEOUT	=	10.0
let INIT_TIMEOU =	10.0
let PENDING_DTC_TIMEOUT =	10.0



// The time, in seconds, after which a location is considered stale
let LOCATION_DECAY_PERIOD =	5.0

open class ScanTool : NSObject {
  weak var delegate : ScanToolDelegate?
  
  
  var supportedSensorList = [Int]()
//  
  open var sensorScanTargets = [UInt8]()
  var currentSensorIndex = 0
//
//  id<FLScanToolDelegate>		_delegate;
  var streamOperation : Operation!
  var scanOperationQueue : OperationQueue!
//  
  var	priorityCommandQueue : [ScanToolCommand] = []
  var	commandQueue : [ScanToolCommand] = []
//  
  var state : ScanToolState = .STATE_INIT
  var `protocol` : ScanToolProtocol = .None
  var	deviceType : ScanToolDeviceType = .Simulated
  var	waitingForVoltageCommand = false
//  BOOL						_useLocation;
//
//  NSTimer*					_batteryTimer;
//  NSTimer*					_pendingCodesTimer;
//  NSTimer*					_deadmanTimer;
//  
  var currentPIDGroup : UInt8 = 0x00
//  
//  NSString*					_host;
//  NSInteger					_port;
  
  var scanning : Bool = false
  var useLocation : Bool = false

  var currentLocation : CLLocation?
  var scanToolName : String = ""
  var scanToolState : ScanToolState = .STATE_INIT
  var scanToolProtocol : ScanToolProtocol = .None
  var scanToolDeviceType : ScanToolDeviceType = .ELM327
  var wifiScanTool : Bool = false //isWifiScanTool
  var eaScanTool : Bool = false   //isEAScanTool
  
  var host = "" //For WiFi ScanTool
  var port = 0  //For WiFi ScanTool
  
  static func scanToolForDeviceType(deviceType : ScanToolDeviceType) -> ScanTool? {
    switch deviceType {
    case .BluTrax:
      return nil
    case .ELM327:
      return ELM327()
    case .GoLink:
      //return GoLink()
      return nil
    default:
      return nil
    }
  }
  
  static func stringForProtocol(`protocol` : ScanToolProtocol) -> String {
    switch `protocol` {
      case .ISO9141Keywords0808:
        return "ISO 9141-2 Keywords 0808"
      case .ISO9141Keywords9494:
        return "ISO 9141-2 Keywords 9494"
      case .KWP2000FastInit:
        return "KWP2000 Fast Init"
      case .KWP2000SlowInit:
        return "KWP2000 Slow Init"
      case .J1850PWM:
        return "J1850 PWM"
      case .J1850VPW:
        return "J1850 VPW"
      case .CAN11bit250KB:
        return "CAN 11-Bit 250Kbps"
      case .CAN11bit500KB:
        return "CAN 11-Bit 500Kbps"
      case .CAN29bit250KB:
        return "CAN 29-Bit 250Kbps"
      case .CAN29bit500KB:
        return "CAN 29-Bit 500Kbps"
      case .None:
        return"Unknown Protocol"
    }
  }
  
  func isWifiScanTool() -> Bool {
    return self is WifiScanTool
  }
  
  func isEAScanTool() -> Bool {
    //return self is FLEAScanTool
    return false
  }
  

  //--------------------------------------------------------------------------
  //------------------------------- CRAZY ABSTRACT ---------------------------
  //--------------------------------------------------------------------------
  
  func initScanTool(){
    // Abstract method
  }

  func commandForPing() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForGenericOBD(mode : ScanToolMode, pid : UInt8, data : Data? = nil) -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForReadSerialNumber() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForReadVersionNumber() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }

  func commandForReadProtocol() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForReadChipID() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForSetAutoSearchMode() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }

  func commandForSetSerialNumber() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForTestForMultipleECUs() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForStartProtocolSearch() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }
  
  func commandForGetBatteryVoltage() -> ScanToolCommand {
    // Abstract method
    return ScanToolCommand()
  }

  func open(){
    // Abstract method
  }
  
  func close(){
    // Abstract method
  }
  
  func sendCommand(command : ScanToolCommand, initCommand : Bool){
    // Abstract method
  }
  
  func getResponse() {
  // Abstract method
  }
  
  func writeCachedData() {
    // Abstract method
  }
  
  func stream(stream : Stream , handleEvent eventCode : Stream.Event) {
    // Abstract method
  }
  
  
  //--------------------------------------------------------------------------
  //------------------------------- CRAZY ABSTRACT ---------------------------
  //--------------------------------------------------------------------------
  
  func setSensorScanTargets(targets : [UInt8]){
    sensorScanTargets.removeAll()
    sensorScanTargets = targets

    guard let cmd = dequeueCommand() else {return}
    sendCommand(command: cmd, initCommand: false)
    writeCachedData()
  }
  
  func isScanning() -> Bool {
    return streamOperation?.isCancelled ?? false
  }
  
  func enqueueCommand(command : ScanToolCommand) {
    priorityCommandQueue.append(command)
  }
  
  func clearCommandQueue(){
    priorityCommandQueue.removeAll()
  }
  
  func dequeueCommand() -> ScanToolCommand? {
    var cmd : ScanToolCommand?
    
    if priorityCommandQueue.count > 0 {
      cmd = priorityCommandQueue.remove(at: 0)
    }else if sensorScanTargets.count > 0 {
      cmd = getCommandForNextSensor()
    }
    
    return cmd
  }
  
  func getCommandForNextSensor() -> ScanToolCommand? {
    if currentSensorIndex >= sensorScanTargets.count {
      currentSensorIndex = 0
      
      // Put a pending DTC request in the priority queue, to be executed
      // after the battery voltage reading
      //[self getPendingTroubleCodes];
      
      if self is ELM327 {
        waitingForVoltageCommand = true
        return self.commandForGetBatteryVoltage()
      }
    }
    
    let next = self.nextSensor()
    
    if next <= 0x4E {
      return commandForGenericOBD(mode: .RequestCurrentPowertrainDiagnosticData, pid: next, data:nil)
    }else {
      return nil
    }
  }
  
  func buildSupportedSensorList(data : Data, pidGroup : Int) -> Bool {
    let bytes = data.withUnsafeBytes {
      [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
    }
    
    let bytesLen = bytes.count
    
    if bytesLen != 4 {
      return false
    }
    
    supportedSensorList = Array.init(repeating: 0, count: 16)
    
    /*	if(pidGroup == 0x00) {
     // If we are re-issuing the PID search command, reset any
     // previously received PIDs
     [_supportedSensorList removeAllObjects];
     [_sensorScanTargets release];
     _sensorScanTargets = nil;
     FLDEBUG(@"Resetting sensor list: %d", [_supportedSensorList count])
     }
     */
    
    var pid = pidGroup + 1
    var supported	= false
    let shiftSize = 7
    
    for i in 0..<4 {
      for y in 0...7 {
        let leftShift = UInt8(shiftSize - y)
        supported   = (((1 << leftShift) & bytes[i]) != 0)
        pid += 1
        
        if(supported) {
          if NOT_SEARCH_PID(pid) && pid <= 0x4E && !supportedSensorList.contains(where: {$0 == pid}){
            supportedSensorList.append(pid)
          }
        }
      }
    }
    
    print("Supported Sensor: \(supportedSensorList.description)")
    print("More PIDs: \(MORE_PIDS_SUPPORTED(bytes))")
    
    return MORE_PIDS_SUPPORTED(bytes)
  }
  
  func isService01PIDSupported(pid : Int) -> Bool {
    var supported = false
    
    for supportedPID in supportedSensorList {
      if supportedPID == pid {
        supported = true
        break
      }
    }
    
    return supported
  }
  
  func nextSensor() -> UInt8 {
    if currentSensorIndex < sensorScanTargets.count {
      currentSensorIndex = 0
    }
    
    let number = sensorScanTargets[currentSensorIndex]
    currentSensorIndex+=1
    
    return number
  }
  
  func commandForNextSensor() -> ScanToolCommand? {
    guard currentSensorIndex < sensorScanTargets.count  else {
      return nil
    }
    
      // Put a pending DTC request in the priority queue, to be executed
      // after the battery voltage reading
      //[self getPendingTroubleCodes];
    
    if self is ELM327 {
      waitingForVoltageCommand = true
      return commandForGetBatteryVoltage()
    }
    
    let next = nextSensor()
    
    if next <= 0x4E {
      return commandForGenericOBD(mode: .RequestCurrentPowertrainDiagnosticData, pid: next, data:nil)
    }else {
      return nil
    }
  }
  
  func dispatchDelegate(){
    //delegate?.
  }
  
  //MARK: - Scanning Operation
  
  open func startScan(){
    priorityCommandQueue.removeAll()
    commandQueue.removeAll()
    supportedSensorList.removeAll()
    sensorScanTargets.removeAll()
    
    state	= .STATE_INIT


    scanOperationQueue = OperationQueue()
    streamOperation = BlockOperation(block: { [weak self] in
      self?.runStreams()
    })

    scanOperationQueue.addOperation(streamOperation)
    scanOperationQueue.isSuspended = false
  }
  
  open func pauseScan(){
    scanOperationQueue.isSuspended = true
  }
  
  open func resumeScan(){
    scanOperationQueue.isSuspended = false
  }
  
  
  func runStreams(){
    let currentRunLoop	= RunLoop.current
    let distantFutureDate	= Date.distantFuture
    
    open()
    delegate?.scanDidStart(scanTool: self)
    initScanTool()
    if isEAScanTool() || isWifiScanTool() {
      while streamOperation?.isCancelled == false && currentRunLoop.run(mode: .defaultRunLoopMode, before: distantFutureDate) {/*loop */}
    }
    
    close()
    delegate?.scanDidCancel(scanTool: self)
  }
  
  func cancelScan(){
    print("ATTEMPTING SCAN CANCELLATION")
    scanOperationQueue.cancelAllOperations()
    streamOperation.cancel()
    
    supportedSensorList.removeAll()
  }
  
  
  func getTroubleCodes(){
    let cmd = commandForGenericOBD(mode: .RequestEmissionRelatedDiagnosticTroubleCodes, pid: 0, data: nil)
    enqueueCommand(command: cmd)
  }
  
  func getPendingTroubleCodes(){
    let cmd = commandForGenericOBD(mode: .RequestEmissionRelatedDiagnosticTroubleCodesDetected, pid: 0, data: nil)
    enqueueCommand(command: cmd)
  }
  
  func clearTroubleCodes(){
    let cmd1 = commandForGenericOBD(mode: .ClearResetEmissionRelatedDiagnosticInfo , pid: 0, data: nil)
    enqueueCommand(command: cmd1)
    //send Mode 0x01 Pid 0x01 cmd after clear to update sensor trouble code count
    let cmd2 = commandForGenericOBD(mode: .RequestCurrentPowertrainDiagnosticData  , pid: 0x01, data: nil)
    enqueueCommand(command: cmd2)
  }
  
  func getBatteryVoltage(){
    enqueueCommand(command: self.commandForGetBatteryVoltage())
  }
  
  
  func didReceiveResponses(responses : [ScanToolResponse]) {
    guard responses.count > 0 else {
      didReceiveNoDATA()
      return
    }

    for response in responses {
      let isMode01 = response.mode == ScanToolMode.RequestCurrentPowertrainDiagnosticData.rawValue
      let isMode02 = response.mode == ScanToolMode.RequestPowertrainFreezeFrameData.rawValue
      let isMode04 = response.mode == ScanToolMode.ClearResetEmissionRelatedDiagnosticInfo.rawValue
      
      if isMode01 || isMode02 {
        if let sensor = ECUSensor.sensorForPID(pid: response.pid) {
          sensor.currentResponse = response
          delegate?.didUpdateSensor(sensor: sensor)
        }else{
          delegate?.didReceiveResponse(scanTool: self, responses: responses)
        }
      }else if isMode04 {
        didClearTroubleCodes(response: response)
      }else if(response.mode == ScanToolMode.RequestVehicleInfo.rawValue){ // MODE 9
        didUpdate9Mode(response: response)
      }else if(response.mode == ScanToolMode.RequestEmissionRelatedDiagnosticTroubleCodes.rawValue){ // MODE 3
        didUpdate3Mode(response : response)
      }else if(response.mode == 64){ // AT Commands
        didUpdateATCommand(response: response)
      }
    }
  }
  
  func didReceiveNoDATA(){
    //[delegate scanToolDidReceiveNoData:self];
  }

  func didUpdate3Mode(response : ScanToolResponse){
  
  }
  
  func didUpdateATCommand(response : ScanToolResponse){
     // [delegate scanTool:self didReceiveATCommand:response];
  }
  
  func didUpdate9Mode(response : ScanToolResponse){
    // [delegate scanTool:self didUpdate9Mode:response];
  }
  
  func didClearTroubleCodes(response : ScanToolResponse){
    // [delegate scanTool:self didClearTroubleCodes:response];
  }
  
  func didUpdateSensor(sensor : ECUSensor){
    // [delegate scanTool:self didClearTroubleCodes:response];
  }

  func startScanWithSensors(){
    
  }
}

