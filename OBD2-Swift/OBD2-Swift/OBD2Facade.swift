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

public protocol CommandType {
  associatedtype Descriptor : DescriptorProtocol
  var mode : Mode {get}
  var commandForRequest : Command {get}
}

public struct CommandE {
  public enum Mode01 : CommandType {
    public typealias Descriptor = Mode01Descriptor
    
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
    case setDeviceIdentifier
    
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
      case .setDeviceIdentifier:
        return Command(from: "AT @3")
      }
    }
  }
  
  //TODO:- Create Descriptor for dynamic comand
  public enum Custom : CommandType {
    public typealias Descriptor = StringDescriptor
    
    case string(String)
    case digit(mode : Int, pid : Int)
    
    public var mode : Mode {
      switch self {
      case .string(let string):
        return encodeMode(from: string)
      case .digit(let mode, _):
        return Mode.init(rawValue: Mode.RawValue(mode)) ?? .none
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
    
    private func encodeMode(from str : String) -> Mode {
      let index = str.index(str.startIndex, offsetBy: 1)
      let modeSubStr = str.substring(to: index)
      let modeRaw = UInt8(modeSubStr) ?? 0
      
      return Mode.init(rawValue: modeRaw) ?? .none
    }
  }
}

