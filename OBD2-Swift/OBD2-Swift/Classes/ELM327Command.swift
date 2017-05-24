//
//  ELM327Command.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 26/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

let kCarriageReturn						= "\r"

// Common Commands
let kELM327Reset						= "AT WS"
let kELM327HeadersOn					= "AT H1"
let kELM327EchoOff						= "AT E0"
let kELM327ReadVoltage					= "AT RV"
let kELM327ReadProtocol					= "AT DP"
let kELM327ReadProtocolNumber			= "AT DPN"
let kELM327ReadVersionID				= "AT I"
let kELM327ReadDeviceDescription		= "AT @1"
let kELM327ReadDeviceIdentifier			= "AT @2"
let kELM327SetDeviceIdentifier			= "AT @3"

class ELM327Command : ScanToolCommand {
  var	commandType : ELM327CommandType = .ELM327ATCommand
  var command = ""
  
  static func commandForOBD2(mode : ScanToolMode, pid : UInt8, data : Data? = nil)-> ELM327Command {
    var cmd = ELM327Command()

    if pid >= 0x00 && pid <= 0x4E {
      let nsStr = NSString.init(format: "%02lx %02lx", mode.rawValue, pid)
      cmd = cmd.initWithCommandString(String(nsStr))
    }else {
      let nsStr = NSString.init(format: "%02lx", mode.rawValue)
      cmd = cmd.initWithCommandString(String(nsStr))
    }
    
    cmd.data = data
    return cmd
  }
  
  static var commandForReset = ELM327Command().initWithCommandString(kELM327Reset)
  
  static var commandForHeadersOn = ELM327Command().initWithCommandString(kELM327HeadersOn)
  
  static var commandForEchoOff = ELM327Command().initWithCommandString(kELM327EchoOff)
    
  static var commandForReadVoltage = ELM327Command().initWithCommandString(kELM327ReadVoltage)
  
  static var commandForReadProtocol = ELM327Command().initWithCommandString(kELM327ReadProtocol)
      
  static var commandForReadVersionID = ELM327Command().initWithCommandString(kELM327ReadVersionID)

  static var commandForReadDeviceDescription = ELM327Command().initWithCommandString(kELM327ReadDeviceDescription)
  
  static var commandForReadDeviceIdentifier = ELM327Command().initWithCommandString(kELM327ReadDeviceIdentifier)
  
  static func commandForSetDeviceIdentifier(identifier : String) -> ELM327Command {
    return ELM327Command().initWithCommandString(kELM327SetDeviceIdentifier + " " + identifier)
  }
  
  func initWithCommandString(_ command : String) -> ELM327Command {
    self.command = command
    return self
  }
  
  func getData() -> Data? {
    command.append(kCarriageReturn)
    return command.data(using: .ascii)
  }
}

