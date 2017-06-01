//
//  InitScanerOperation.swift
//  OBD2Swift
//
//  Created by Sergiy Loza on 30.05.17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

protocol BytesAvailable {
    
    var onBytesAvailable:((_ stream:InputStream) -> ())? { get set }
}

enum InitializationError: Error {
    case DefaultError
}

class InitScanerOperation: StreamHandleOperation, BytesAvailable {
    
    var onBytesAvailable: ((InputStream) -> ())?
    
    private var currentPIDGroup: UInt8 = 0x00

    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
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
    
    override func inputStremEvent(event: Stream.Event) {
        if event == .hasBytesAvailable {
            do {
                if try reader.read() {
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
