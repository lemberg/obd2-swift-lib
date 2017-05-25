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

class StreamHolder : NSObject {
  var delegate : StreamFlowDelegate?
  var inputStream : InputStream!
  var outputStream : OutputStream!
  var cachedWriteData = Data()
  
  var host = ""
  var port = 0
  
  func open(){
    var readStream:  Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    CFStreamCreatePairWithSocketToHost(nil, host as CFString, UInt32(port), &readStream, &writeStream)
    
    self.inputStream = readStream!.takeRetainedValue()
    self.outputStream = writeStream!.takeRetainedValue()
    
    self.inputStream.delegate = self
    self.outputStream.delegate = self
    
    self.inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    self.outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    
    self.inputStream.open()
    self.outputStream.open()
  }
  
  func close(){
    self.inputStream.delegate = nil
    self.outputStream.delegate = nil
    
    self.inputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    self.outputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    
    self.inputStream.close()
    self.outputStream.close()
  }
  
  func writeCachedData() {
    var status : Stream.Status = .error
    
    while cachedWriteData.count > 0 {
      let bytesWritten = write(data: cachedWriteData)
      print("bytesWritten = \(bytesWritten)")
      
      if bytesWritten == -1 {
        print("Write Error")
        break
      }else if bytesWritten > 0 && cachedWriteData.count > 0 {
        print("Wrote \(bytesWritten) bytes")
        cachedWriteData.removeSubrange(0..<bytesWritten)
      }
    }
    
    cachedWriteData.removeAll()
    
    print("OutputStream status = \(outputStream.streamStatus)")
    print("Starting write wait")
    
    repeat {
      status = outputStream.streamStatus
    } while status == Stream.Status.writing
  }
  
  func write(data : Data) -> Int {
    var bytesRemaining = data.count
    var totalBytesWritten = 0
    
    while bytesRemaining > 0 {
      let bytesWritten = data.withUnsafeBytes {
        outputStream.write(
          $0.advanced(by: totalBytesWritten),
          maxLength: bytesRemaining
        )
      }
      if bytesWritten < 0 {
        print("Can not OutputStream.write()   \(outputStream.streamError?.localizedDescription ?? "")")
        return -1
      } else if bytesWritten == 0 {
        print("OutputStream.write() returned 0")
        return totalBytesWritten
      }
      
      bytesRemaining -= bytesWritten
      totalBytesWritten += bytesWritten
    }
    
    return totalBytesWritten
  }

  func handleInputEvent(_ eventCode : Stream.Event){
    if eventCode == .openCompleted {
      print("NSStreamEventOpenCompleted")
      delegate?.didOpen(stream: inputStream)
    }else if eventCode == .hasBytesAvailable {
      print("NSStreamEventHasBytesAvailable")
      delegate?.hasInput(on: inputStream)
    }else if eventCode == .errorOccurred {
      print("NSStreamEventErrorOccurred")
      
      if let error = inputStream.streamError {
        print(error.localizedDescription)
        delegate?.error(error, on: inputStream)
      }
    }
  }
  
  func handleOutputEvent(_ eventCode : Stream.Event){
    if eventCode == .openCompleted {
      delegate?.didOpen(stream: outputStream)
      print("NSStreamEventOpenCompleted")
    }else if eventCode == .hasSpaceAvailable {
      print("NSStreamEventHasBytesAvailable")
      writeCachedData()
    }else if eventCode == .errorOccurred {
      print("NSStreamEventErrorOccurred")
      if let error = inputStream.streamError {
        print(error.localizedDescription)
        delegate?.error(error, on: outputStream)
      }
    }
  }
}

extension StreamHolder : StreamDelegate {
  public func stream(_ aStream: Stream, handle eventCode: Stream.Event){
    if aStream == inputStream {
      handleInputEvent(eventCode)
    }else if aStream == outputStream {
      handleOutputEvent(eventCode)
    }else {
      print("Received event for unknown stream")
    }
  }
}
