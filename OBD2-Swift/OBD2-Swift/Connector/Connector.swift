//
//  Connector.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class Connector {
  typealias CallBack = (Bool, Error?)->()
  
  private var currentPIDGroup : UInt8 = 0x00
  weak var scanner : Scanner?

  
  var state : State = .unknown
  
  func setup(using buffer : [UInt8]){
    let respString = toString(buffer)
    
    if isError(response: respString) {
      state = .unknown
    }
    
    switch state {
    case .unknown:
      state.next()
      //delegate?.reset()
      break
    case .reset:
      state.next()
      //delegate?.scanToolDidConnect(scanTool: self)
      break
    case .echoOff:
      guard isOK(respString) else {
        //TODO: - Error
        print("Error response from ELM327 during Echo Off: \(String(describing: respString))")
        return
      }
      
      state.next()
      
      break
    case .`protocol`:
      if scanner?.setupProtocol(buffer: buffer) != .none {
        state.next()
        setup(using: buffer)
        return
      }else{
        //Fail to setup protocol
      }
    case .version:
      state.next()
      break
    case .search:
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
          state.next()
          currentPIDGroup	= 0x00
        }
      }else{
        state.next()
        currentPIDGroup	= 0x00
      }

      break
    case .complete:
      //delegate?.scanToolDidInitialize(scanTool: self)
      scanner?.setupReady()
      break
    }
    
    if let cmd = command(for: state) {
      scanner?.request(command: cmd)
    }else{

    }
  }
  
  
  private func buildSupportedSensorList(data : Data, pidGroup : Int) -> Bool {
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
    
    scanner?.supportedSensorList = supportedSensorList
    
    return MORE_PIDS_SUPPORTED(bytes)
  }
  
  private func isError(response str : String) -> Bool {
    return str.contains("?")
  }
  
  private func isOK(_ str : String) -> Bool{
    return str.contains("OK")
  }
  
  private func toString(_ buffer : [UInt8]) -> String {
    let asciistr : [Int8] = buffer.map({Int8.init(bitPattern: $0)})
    return String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
  }
  
  private func command(for state : State) -> Command? {
    var cmd : Command?
    switch (state) {
    case .reset:
      cmd = Command.reset
      break
    case .echoOff:
      cmd = Command.echoOff
      break
    case .`protocol`:
      cmd = Command.protocol
      break
    case .version:
      cmd = Command.versionId
      break
    case .search:
      cmd = Command.create(mode: .RequestCurrentPowertrainDiagnosticData,
                           pid: currentPIDGroup)
      break
    default:
      break
    }
    return cmd
  }
}


extension Connector {
  enum State : UInt {
    case unknown			= 0
    case reset				= 1
    case echoOff			= 2
    case version 			= 4
    case search       = 8
    case `protocol`		= 16
    case complete     = 32
    
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
