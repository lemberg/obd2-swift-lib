//
//  OBD2Facade.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


protocol ScanDelegate {
  func didReceive()
}

open class OBD2 {
  private var host : String
  private var port : Int
  
  var scanner : Scanner
  var connector : Connector
  //var observer : SensorObserver

  public convenience init(){
    self.init(host : "192.168.0.10", port : 35000)
  }
  
  public init(host : String, port : Int){
    self.host = host
    self.port = port
    
    self.connector = Connector()
    //self.observer = SensorObserver()
    self.scanner = Scanner(host: host, port: port)
    
    connector.scanner = scanner
    scanner.connector = connector
    //scanner.observer = observer
  }
  
  var logger : Any?
  var cache : Any?
  
  public func connect(_ block : Connector.CallBack){
    scanner.startScan()
  }
  
  public func disconnect(){
    //
  }
  
  public func startScan(){
    
  }
  
  public func stopScan(){
    
  }
  
  public func setSensors(){
    
  }
  
  public func requestTroubleCodes(){
    scanner.request(command: Command.init(from: "03"))
  }
  
  public func requestVIN(){
    scanner.request(command: Command.init(from: "0902"))
  }
  
  public func request(command str: String){
    scanner.request(command: Command.init(from: str))
  }
  
  public func request<T : CommandType>(command : T, block : (_ descriptor : T.Descriptor?)->()){
    let cmd = command.commandForRequest
    
    let described = T.Descriptor(describe: Response())
    block(described)
  }
}

public protocol CommandPrototype : Hashable, Equatable {
  var mode : Mode {get}
  var commandForRequest : Command {get}
}

public protocol CommandType : CommandPrototype {
  associatedtype Descriptor : DescriptorProtocol
}

public struct CommandE {
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
    
    public var commandForRequest : Command {
      switch self {
      case .pid(number: let pid):
        return Command(mode: mode, pid: UInt8(pid))
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
    
    public var commandForRequest : Command {
      return Command(from: "03")
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
    
    public var commandForRequest : Command {
      switch self {
      case .reset:
        return Command(from: "AT WS")
      case .headersOn:
        return Command(from: "AT H1")
      case .echoOff:
        return Command(from: "AT E0")
      case .voltage:
        return Command(from: "AT RV")
      case .`protocol`:
        return Command(from: "AT DP")
      case .protocolNumber:
        return Command(from: "AT DPN")
      case .versionId:
        return Command(from: "AT I")
      case .deviceDescription:
        return Command(from: "AT @1")
      case .readDeviceIdentifier:
        return Command(from: "AT @2")
      case .setDeviceIdentifier(let identifier):
        return Command(from: "AT @2 " + identifier)
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
    
    public var commandForRequest : Command {
      switch self {
      case .string(let string):
        let uppercasedStr = string.uppercased()
        return Command(from: uppercasedStr)
      case .digit(let mode, let pid):
        let mode = Mode.init(rawValue: UInt8(mode)) ?? .none
        return Command(mode: mode, pid: UInt8(pid))
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

