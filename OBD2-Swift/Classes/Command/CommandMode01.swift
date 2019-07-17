//
//  CommandMode01.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 07/06/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public extension Command {
  
  enum Mode01 : CommandType {
    
    public typealias Descriptor = Mode01Descriptor
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .pid(number : let pid):
            hasher.combine(Int(mode.rawValue) ^ pid)
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
}
