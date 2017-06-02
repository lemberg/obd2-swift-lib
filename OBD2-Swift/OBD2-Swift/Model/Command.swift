//
//  Command.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 02/06/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


public protocol CommandPrototype : Hashable, Equatable {
  var mode : Mode {get}
  var dataRequest : DataRequest {get}
}

public protocol CommandType : CommandPrototype {
  associatedtype Descriptor : DescriptorProtocol
}


public struct Command {
  
  public enum Mode01 : CommandType {
    public typealias Descriptor = Mode01Descriptor
    
    public var hashValue: Int {
      switch self {
      case .pid(number : let pid):
        return Int(mode.rawValue) ^ pid
      }
    }
    
    public static func ==(lhs: Mode01, rhs: Mode01) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }
    
    case pid(number : Int)
    
    public var mode : Mode {
      return .CurrentData01
    }
    
    public var dataRequest : DataRequest {
      switch self {
      case .pid(number: let pid):
        return DataRequest(mode: mode, pid: UInt8(pid))
      }
    }
    
  }
  
  public enum Mode03 : CommandType {
    
    public typealias Descriptor = Mode03Descriptor
    
    public var hashValue: Int {
      return Int(mode.rawValue) ^ 0
    }
    
    public static func == (lhs: Mode03, rhs: Mode03) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }
    
    case troubleCode
    
    public var mode : Mode {
      return .DiagnosticTroubleCodes03
    }
    
    public var dataRequest : DataRequest {
      return DataRequest(from: "03")
    }
    
  }
  
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
      let modeSubStr = str.substring(to: index)
      let modeRaw = UInt8(modeSubStr) ?? 0
      
      return Mode.init(rawValue: modeRaw) ?? .none
    }
    
    private func encodePid(from string : String) -> UInt8 {
      let str = string.replacingOccurrences(of: " ", with: "")
      let index = str.index(str.startIndex, offsetBy: 1)
      let pidSubStr = str.substring(from: index)
      let pidRaw = UInt8(pidSubStr) ?? 0x00
      
      return pidRaw
    }
    
  }
}
