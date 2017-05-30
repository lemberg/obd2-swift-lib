//
//  Command.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class Command {
    
  enum AT : String {
    case reset                = "AT WS"
    case headersOn            = "AT H1"
    case echoOff              = "AT E0"
    case voltage              = "AT RV"
    case `protocol`           = "AT DP"
    case protocolNumber       = "AT DPN"
    case versionId            = "AT I"
    case deviceDescription	  = "AT @1"
    case readDeviceIdentifier = "AT @2"
    case setDeviceIdentifier  = "AT @3"
  }
  
  enum Make {
    case AT
    case defaul
  }
  
  var	type = Command.Make.defaul
  var description = ""
  
  init(from string : String) {
    self.description = string
  }
  
  convenience init(from type : Command.AT) {
    self.init(from: type.rawValue)
  }
  
  static func create(mode : ScanToolMode, pid : UInt8, param : String? = nil)-> Command {
    var cmd : Command!
    
    if pid >= 0x00 && pid <= 0x4E {
      let nsStr = NSString.init(format: "%02lx %02lx", mode.rawValue, pid)
      cmd = Command(from : String(nsStr))
    }else {
      let nsStr = NSString.init(format: "%02lx", mode.rawValue)
      cmd = Command(from : String(nsStr))
    }
    
    if let param = param {
      cmd.description += (" " + param)
    }

    return cmd
  }
  
  static var reset = Command(from : Command.AT.reset)
  
  static var headersOn = Command(from : Command.AT.headersOn)
  
  static var echoOff = Command(from : Command.AT.echoOff)
  
  static var voltage = Command(from : Command.AT.voltage)
  
  static var `protocol` = Command(from : Command.AT.protocol)
  
  static var versionId = Command(from : Command.AT.versionId)
  
  static var deviceDescription = Command(from : Command.AT.deviceDescription)
  
  static var readDeviceIdentifier = Command(from :Command.AT.readDeviceIdentifier)
  
  static func setDeviceIdentifier(identifier : String) -> Command {
    return Command(from : Command.AT.setDeviceIdentifier.rawValue + " " + identifier)
  }
  
  func getData() -> Data? {
    description.append(kCarriageReturn)
    return description.data(using: .ascii)
  }
}
