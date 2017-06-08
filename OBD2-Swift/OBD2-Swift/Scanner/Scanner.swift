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
    
    typealias CallBack = (Bool, Error?) -> ()
    
    let timeout	=	10.0
    
    var defaultSensors: [UInt8] = [0x0C, 0x0D]
    
    var supportedSensorList = [Int]()
    open var sensorScanTargets = [UInt8]()
    
    var currentSensorIndex = 0
    var streamOperation: Operation!
    var scanOperationQueue: OperationQueue!
    
    var priorityCommandQueue: [DataRequest] = []
    var commandQueue: [DataRequest] = []
    
    var state: ScanState = .none {
        didSet {
            if state == .none {
                obdQueue.cancelAllOperations()
            }
        }
    }
    
    var `protocol`: ScanProtocol = .none
    var waitingForVoltageCommand = false
    var currentPIDGroup: UInt8 = 0x00
    
    var maxSize = 512
    var readBuf = [UInt8]()
    var readBufLength = 0
    
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
    
    open func request(command: DataRequest) {
        self.request(command: command) { (response) in
            print("Receive response \(response)")
        }
    }
    
    
    open func request(command: DataRequest, response : @escaping (_ response:Response) -> ()){
        
        let request = CommandOperation(inputStream: inputStream, outputStream: outputStream, command: command)
        
        request.onReceiveResponse = response
        
        request.completionBlock = {
            print("Request operation completed")
        }
        
        obdQueue.addOperation(request)
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
    
    open func startScan(callback: @escaping CallBack){

        if state != .none {
            return
        }
        
        state = .connecting
        
        open()
        
        let op = InitScanerOperation(inputStream: inputStream, outputStream: outputStream)
        
        op.completionBlock = {
            if let error = op.error {
                callback(false, error)
            } else {
                self.state = .connected
                callback(true, nil)
            }
        }
        
        obdQueue.addOperation(op)
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

    private func enqueueCommand(command: DataRequest) {
        priorityCommandQueue.append(command)
    }
    
    private func clearCommandQueue(){
        priorityCommandQueue.removeAll()
    }
    
    private func dequeueCommand() -> DataRequest? {
        var cmd: DataRequest?
        
        if priorityCommandQueue.count > 0 {
            cmd = priorityCommandQueue.remove(at: 0)
        }else if sensorScanTargets.count > 0 {
            cmd = commandForNextSensor()
        }
        
        return cmd
    }
    
    private func commandForNextSensor() -> DataRequest? {
        if currentSensorIndex >= sensorScanTargets.count {
            currentSensorIndex = 0
            
            // Put a pending DTC request in the priority queue, to be executed
            // after the battery voltage reading
            
            waitingForVoltageCommand = true
            return Command.AT.reset.dataRequest
        }
        
        let next = self.nextSensor()
        
        if next <= 0x4E {
            return DataRequest(mode: .CurrentData01, pid: next)
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
        //
        //    do {
        //    
        //        if state == .init {
        //          try readInitResponse()
        //        } else if state == .idle || state == .waiting {
        //            waitingForVoltageCommand ? readVoltageResponse() : readInput()
        //
        //        } else {
        //          print("Error: Received bytes in unknown state: \(state)")
        //        }
        //        
        //    } catch {
        //        
        //        print("Error: Init response unreadable. Need reconnect")
        //        //TODO: try reconnect    
        //    }
        //    
        //    
    }
}

extension Scanner {
    enum State : UInt {
        case unknown			= 1
        case reset				= 2
        case echoOff			= 4
        case version 			= 8
        case search       = 16
        case `protocol`   = 32
        case complete     = 64
        
        static var all : [State] {
            return [.unknown, .reset, .echoOff, .version, .search, .`protocol`, .complete]
        }
        
        static func <<= (left: State, right: UInt) -> State {
            let move = left.rawValue << right
            return self.all.filter({$0.rawValue == move}).first ?? .unknown
        }
        
        mutating func next() {
            self = self <<= 1
        }
    }
}
