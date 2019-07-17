//
//  Mode09.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 02/06/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


public extension Command {
  enum Mode09 : CommandType {
    
    public typealias Descriptor = Mode09Descriptor
    
    case vin            //Vehicle Identification Number
    case calibrationID  //Only for ISO 9141-2, ISO 14230-4 and SAE J1850.
    case cvn            //Calibration verification numbers
    case performanceTrackingMessage
    case ECUname
    
    public static func == (lhs: Mode09, rhs: Mode09) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Int(mode.rawValue ^ pid))
    }
    
    public var mode : Mode {
      return .RequestVehicleInfo09
    }
    
    var pid : UInt8 {
      switch self {
      case .vin:
        return 0x02
      case .calibrationID:
        return 0x04
      case .cvn:
        return 0x06
      case .performanceTrackingMessage:
        return 0x07
      case .ECUname:
        return 0x0A
      }
    }
    
    public var dataRequest : DataRequest {
      return DataRequest(mode: mode, pid: pid)
    }
    
  }
}
