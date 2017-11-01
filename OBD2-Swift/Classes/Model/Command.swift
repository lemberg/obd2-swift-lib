//
//  Command.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 02/06/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


public protocol CommandPrototype : Hashable {
  var mode : Mode {get}
  var dataRequest : DataRequest {get}
}

public protocol CommandType : CommandPrototype {
  associatedtype Descriptor : DescriptorProtocol
}


public struct Command {
  // This struct includes extension enum
  // Mode01 , Mode02 , Mode03
  // @see CommandMode01 - 09.swift
  
  public enum AT : CommandType {
    
    public typealias Descriptor = StringDescriptor
    
    case reset
    case headersOn
    case echoOff
    case voltage
    case `protocol`
    case protocolNumber
    case versionId
    case deviceDescription
    case readDeviceIdentifier
    case setDeviceIdentifier(String)
    
    public var hashValue: Int {
      return Int(mode.rawValue ^ mode.rawValue)
    }
    
    public static func == (lhs: AT, rhs: AT) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }
    
    public var mode : Mode {
      return .none
    }
    
    public var dataRequest : DataRequest {
      switch self {
      case .reset:
        return DataRequest(from: "AT WS")
      case .headersOn:
        return DataRequest(from: "AT H1")
      case .echoOff:
        return DataRequest(from: "AT E0")
      case .voltage:
        return DataRequest(from: "AT RV")
      case .`protocol`:
        return DataRequest(from: "AT DP")
      case .protocolNumber:
        return DataRequest(from: "AT DPN")
      case .versionId:
        return DataRequest(from: "AT I")
      case .deviceDescription:
        return DataRequest(from: "AT @1")
      case .readDeviceIdentifier:
        return DataRequest(from: "AT @2")
      case .setDeviceIdentifier(let identifier):
        return DataRequest(from: "AT @2 " + identifier)
      }
    }
    
  }
  
  //TODO:- Create Descriptor for dynamic comand
  public enum Custom : CommandType {
    
    public typealias Descriptor = StringDescriptor
    
    case string(String)
    case digit(mode : Int, pid : Int)
    
    public var hashValue: Int {
      return Int(mode.rawValue ^ pid)
    }
    
    public static func == (lhs: Custom, rhs: Custom) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }
    
    public var mode : Mode {
      switch self {
      case .string(let string):
        return encodeMode(from: string)
      case .digit(let mode, _):
        return Mode.init(rawValue: Mode.RawValue(mode)) ?? .none
      }
    }
    
    public var pid : UInt8 {
      switch self {
      case .string(let string):
        return encodePid(from: string)
      case .digit(_, let pid):
        return UInt8(pid)
      }
    }
    
    public var dataRequest : DataRequest {
      switch self {
      case .string(let string):
        let uppercasedStr = string.uppercased()
        return DataRequest(from: uppercasedStr)
      case .digit(let mode, let pid):
        let mode = Mode.init(rawValue: UInt8(mode)) ?? .none
        return DataRequest(mode: mode, pid: UInt8(pid))
      }
    }
    
    private func encodeMode(from string : String) -> Mode {
      let str = string.replacingOccurrences(of: " ", with: "")
      let index = str.index(str.startIndex, offsetBy: 1)
      let modeSubStr = str.prefix(upTo: index)
      let modeRaw = UInt8(modeSubStr) ?? 0
      return Mode.init(rawValue: modeRaw) ?? .none
    }
    
    private func encodePid(from string : String) -> UInt8 {
      let str = string.replacingOccurrences(of: " ", with: "")
      let index = str.index(str.startIndex, offsetBy: 1)
      let pidSubStr = str.suffix(from: index)
      let pidRaw = UInt8(pidSubStr) ?? 0x00
      return pidRaw
    }
    
  }
}
