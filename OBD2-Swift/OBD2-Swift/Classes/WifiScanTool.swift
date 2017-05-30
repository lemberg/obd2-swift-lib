//
//  WifiScanTool.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

open class WifiScanTool : ScanTool {
  var inputStream : InputStream!
  var outputStream : OutputStream!
  var cachedWriteData = Data()
  var spaceAvailable = false
  
  override func open(){
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
  
  override func close(){
    self.inputStream.delegate = nil
    self.outputStream.delegate = nil
    
    self.inputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    self.outputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    
    self.inputStream.close()
    self.outputStream.close()
  }
  
  override func sendCommand(command : ScanToolCommand, initCommand : Bool){
    if let cmd = command as? ELM327Command, let data = cmd.getData() {
      cachedWriteData.append(data)
    }else{
      if let data = command.data {
        cachedWriteData.append(data)
      }
    }
    
    writeCachedData()
  }
  
  override func getResponse(){
    self.stream(inputStream, handle : Stream.Event.hasBytesAvailable)
  }
  
  override func writeCachedData() {
    guard !streamOperation.isCancelled else {return}
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
      
        
//        if (bytesWritten == -1) {
//          FLERROR(@"Write Error", nil)
//          break;
//        }
//        else if(bytesWritten > 0 && [_cachedWriteData length] > 0) {
//          FLDEBUG(@"Wrote %d bytes", bytesWritten)
//          [_cachedWriteData replaceBytesInRange:NSMakeRange(0, bytesWritten)
//            withBytes:NULL
//            length:0];
//        }
    }

    
    cachedWriteData.removeAll()
    
    print("OutputStream status = \(outputStream.streamStatus.rawValue)")
    print("Starting write wait")
    
    repeat {
      status = outputStream.streamStatus
    } while status == Stream.Status.writing
    
    print("Exit")
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
}

extension WifiScanTool : StreamDelegate {
  public func stream(_ aStream: Stream, handle eventCode: Stream.Event){
    self.stream(stream : aStream, handleEvent: eventCode)
  }
}
