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

class InitScanerOperation: StreamHandleOperation, BytesAvailable {
    
    var onBytesAvailable: ((InputStream) -> ())?
    
    private(set) var command: Command
    
    override var isFinished: Bool {
        return false
    }
    
    init(inputStream: InputStream, outputStream: OutputStream, command: Command) {
        self.command = command
        super.init(inputStream: inputStream, outputStream: outputStream)
    }
    
    override func main() {
        super.main()
    }
    
    override func execute() {
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
            onBytesAvailable?(input)
        }
    }
    
    override func outputStremEvent(event: Stream.Event) {
        
    }
}
