//
//  InitScanerOperation.swift
//  OBD2Swift
//
//  Created by Sergiy Loza on 30.05.17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum InitializationError: Error {
    case DefaultError
}

class InitScanerOperation: StreamHandleOperation {
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }

    private(set) var currentPIDGroup: UInt8 = 0x00 {
        didSet {
            print("Set new pid group \(currentPIDGroup)")
        }
    }

    
    private(set) var `protocol`:ScanProtocol?
    
    var command: Command {
        switch state {
        case .reset:
            return Command.reset
        case .echoOff:
            return Command.echoOff
        case .`protocol`:
            return Command.protocol
        case .version:
            return Command.versionId
        case .search:
            return Command.create(mode: .RequestCurrentPowertrainDiagnosticData,
                                 pid: currentPIDGroup)
        default:
            return .reset
        }
    }
    
    private var reader:StreamReader
    
    private var state:Connector.State = .unknown {
        didSet{
            if state == .complete {
                input.remove(from: .current, forMode: .defaultRunLoopMode)
                output.remove(from: .current, forMode: .defaultRunLoopMode)
            }
        }
    }
    
    override var isFinished: Bool {
        return state == .complete
    }
    
    override init(inputStream: InputStream, outputStream: OutputStream) {
        self.reader = StreamReader(stream: inputStream)
        super.init(inputStream: inputStream, outputStream: outputStream)
    }
    
    override func main() {
        super.main()
    }
    
    override func execute() {
        state.next()
        continueInitialization()
    }
    
    private func continueInitialization() {
        
        //Create new reader for comand
        self.reader = StreamReader(stream: input)
        
        //Get comand data and write it
        guard let data = command.getData() else { return }
        let writer = StreamWriter(stream: output, data: data)
        do {
            try writer.write()
        } catch let error {
            print("Error \(error) on data writing")
        }
    }
    
    private func onReadEnd() {
        switch state {
        case .echoOff:
            guard let resp = reader.response, resp.elmOK else {
                print("Stop initialization, error during echo off")
                return
            }
            break
        case .`protocol`:
            guard let response = reader.response else {
                print("Handle protocol setup error")
                return
            }
            var searchIndex = 0
            if Parser.string.isAuto(response) {
                searchIndex += 1
            }
            
            let index = reader.readBuffer[searchIndex] - 0x4E
            self.`protocol` = elmProtocolMap[Int(index)]
            print("Set OBD protocol to \(String(describing: self.`protocol`))")
            break
        case .search:
            let buffer = reader.readBuffer
            
            let parser = ELM327ResponseParser(with: buffer, length: buffer.count)
            let responses = parser.parseResponse(protocol: .none)
            
            var extendPIDSearch	= false
            
            for resp in responses {
                let morePIDs = buildSupportedSensorList(data: resp.data!, pidGroup: Int(currentPIDGroup))
                
                if !extendPIDSearch && morePIDs {
                    extendPIDSearch	= true
                }
            }
            
            currentPIDGroup	+= extendPIDSearch ? 0x20 : 0x00
            
            if extendPIDSearch {
                if currentPIDGroup > 0x40 {
                    currentPIDGroup	= 0x00
                }
            }else{
                currentPIDGroup	= 0x00
            }

            
            break
        default:
            break
        }
    }
    
    override func inputStremEvent(event: Stream.Event) {
        if event == .hasBytesAvailable {
            do {
                if try reader.read() {
                    onReadEnd()
                    state.next()
                    continueInitialization()
                }
            } catch StreamReaderError.noBytesReaded {
                print("No bytes error")
            } catch StreamReaderError.ELMError {
                print("ELM error")
            } catch {
                print("Unknown reader error")
            }
        }
    }
    
    override func outputStremEvent(event: Stream.Event) {
        
    }
}

fileprivate func buildSupportedSensorList(data : Data, pidGroup : Int) -> Bool {
    
    let bytes = data.withUnsafeBytes {
        [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
    }
    
    let bytesLen = bytes.count
    
    if bytesLen != 4 {
        return false
    }
    
    var supportedSensorList = Array.init(repeating: 0, count: 16)
    
    /*	if(pidGroup == 0x00) {
     // If we are re-issuing the PID search command, reset any
     // previously received PIDs
     */
    
    var pid         = pidGroup + 1
    var supported	= false
    let shiftSize   = 7
    
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
    
    return MORE_PIDS_SUPPORTED(bytes)
}
