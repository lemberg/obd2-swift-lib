//
//  StreamHolder.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

protocol StreamFlowDelegate {
    func didOpen(stream : Stream)
    func error(_ error : Error, on stream : Stream)
    func hasInput(on stream : Stream)
}

class StreamHolder: NSObject {
    
    var delegate : StreamFlowDelegate?
    
    var inputStream : InputStream!
    var outputStream : OutputStream!
    
    let obdQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.obd2.commands"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var cachedWriteData = Data()
    
    var host = ""
    var port = 0

    
    func createStreams() {
        var readStream: InputStream?
        var writeStream: OutputStream?
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &readStream, outputStream: &writeStream)
        guard let a = readStream else { fatalError("Read stream not created") }
        guard let b = writeStream else { fatalError("Write stream not created") }
        self.inputStream = a
        self.outputStream = b
    }
    
    func close(){
        self.inputStream.delegate = nil
        self.outputStream.delegate = nil
        
        self.inputStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        self.outputStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        
        self.inputStream.close()
        self.outputStream.close()
    }
  
  func writeCachedData() {
    
    // TODO: are we needed?
    //    var status : Stream.Status = .error
    
    print("{ ")
    guard outputStream.streamStatus != .writing && inputStream.streamStatus != .writing else {
        print("Data is already writing..!")
        //TODO: test with new operation queue
        return
    }

    while cachedWriteData.count > 0 {
      let bytesWritten = write(data: cachedWriteData)
      print("bytesWritten = \(bytesWritten)")
      
      if bytesWritten == -1 {
        // ~hell
        print("Write Error")
        break
      } else if bytesWritten > 0 && cachedWriteData.count > 0 {
        print("Wrote \(bytesWritten) bytes from \(cachedWriteData.count) cashed bytes")
        cachedWriteData.removeSubrange(0..<bytesWritten)
      }
    }
    
    print(" }")

    cachedWriteData.removeAll()
    
    print("OutputStream status = \(outputStream.streamStatus.rawValue)")
    print("Starting write wait")
    
  }
  
  func write(data: Data) -> Int {
    let bytesRemaining = data.count
    let totalBytesWritten = 0
    
    while bytesRemaining > 0 {
      let bytesWritten = data.withUnsafeBytes {
        outputStream.write(
          $0.advanced(by: totalBytesWritten),
          maxLength: bytesRemaining
        )
      }
      if bytesWritten < 0 {
        print("Can not OutputStream.write() \(outputStream.streamError?.localizedDescription ?? "")")
        return -1
      } else if bytesWritten == 0 {
        print("OutputStream.write() returned 0")
        return totalBytesWritten
    }
    
  }
    return totalBytesWritten
}
  func handleInputEvent(_ eventCode: Stream.Event){
    if eventCode == .openCompleted {
      print("NSStreamEventOpenCompleted")
      delegate?.didOpen(stream: inputStream)
        
    } else if eventCode == .hasBytesAvailable {
      print("NSStreamEventHasBytesAvailable")
      delegate?.hasInput(on: inputStream)
        
    } else if eventCode == .errorOccurred {
      print("NSStreamEventErrorOccurred")
      
      if let error = inputStream.streamError {
        print(error.localizedDescription)
        delegate?.error(error, on: inputStream)
      }
    }
  }
  
    func handleOutputEvent(_ eventCode: Stream.Event){
        if eventCode == .openCompleted {
            delegate?.didOpen(stream: outputStream)
            print("NSStreamEventOpenCompleted")
            
        } else if eventCode == .hasSpaceAvailable {
            print("NSStreamEventHasBytesAvailable")
            writeCachedData()
            
        } else if eventCode == .errorOccurred {
            print("NSStreamEventErrorOccurred")
            if let error = inputStream.streamError {
                print(error.localizedDescription)
                delegate?.error(error, on: outputStream)
            }
        }
    }
}


extension StreamHolder: StreamDelegate {
    
  public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    if aStream == inputStream {
      handleInputEvent(eventCode)
    } else if aStream == outputStream {
      handleOutputEvent(eventCode)
    } else {
      print("Received event for unknown stream")
    }
}
}

