//
//  Descriptor.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public class Mode01Descriptor : DescriptorProtocol {
  public var response : Response
  var descriptor : SensorDescriptor
  
  required public init(describe response : Response) {
    self.response = response
    let pid = response.pid
    self.mode = response.mode
    
    guard pid >= 0x0 && pid <= 0x4E else {
      assertionFailure("Unsuported pid group")
      self.descriptor = SensorDescriptorTable[0]
      return
    }
    self.descriptor = SensorDescriptorTable[Int(pid)]
  }
  
  public var mode : Mode
  public var pid : UInt8 {
    return response.pid
  }
  
  public var valueMetrics : Float? {
    guard let data = response.data else {return nil}
    guard !isAsciiEncoded else {return nil}
    guard let exec = descriptor.calcFunction else {return nil}
    
    return exec(data)
  }
  
  public var valueImperial : Float? {
    guard let value = valueMetrics else {return nil}
    guard let exec = descriptor.convertFunction else {return nil}
    return exec(value)
  }
  
  public var unitsImperial : Float? {
    guard let value = valueMetrics else {return nil}
    guard let exec = descriptor.convertFunction else {return nil}
    return exec(value)
  }
  
  public var asciValue : String? {
    guard let data = response.data else {return nil}
    guard isAsciiEncoded else {return nil}
    return calculateStringForData(data: data)
  }
  
  public var description : String {
    return descriptor.description
  }
  
  public var shortDescription :String {
    return descriptor.shortDescription
  }
  
  public var unitImperial : String {
    return descriptor.imperialUnit
  }
  
  public var unitMetric : String {
    return descriptor.metricUnit
  }
  
  public var isAsciiEncoded : Bool {
    return IS_ALPHA_VALUE(pid: pid)
  }
  
  public func stringRepresentation(metric : Bool, rounded : Bool = false) -> String {
    if isAsciiEncoded {
      return asciValue ?? ""
    }else{
      guard let value = self.value(metric: metric) else {return ""}
      let units = self.units(metric: metric)
      
      if rounded {
        return "\(Int.init(value)) \(units)"
      }else{
        return "\(value) \(units)"
      }
    }
  }
  
  
  public func units(metric : Bool) -> String {
    return metric ? descriptor.metricUnit : descriptor.imperialUnit
  }
  
  public func value(metric : Bool) -> Float? {
    return metric ? valueMetrics : valueImperial
  }
  
  public func minValue(metric : Bool) -> Int {
    if isAsciiEncoded {
      return Int.min
    }
    return metric ? descriptor.minMetricValue : descriptor.minImperialValue
  }
  
  public func maxValue(metric : Bool) -> Int {
    if isAsciiEncoded {
      return Int.max
    }
    
    return metric ? descriptor.maxMetricValue : descriptor.maxImperialValue
  }
  
  //TODO: - Add multidescriptor to descriptor tables
  //    public func isMultiValue() -> Bool {
  //        return IS_MULTI_VALUE_SENSOR(pid: pid)
  //    }
  
  //MARK: - String Calculation Methods
  
  private func calculateStringForData(data : Data) -> String? {
    switch pid {
    case 0x03:
      return calculateFuelSystemStatus(data)
    case 0x12:
      return calculateSecondaryAirStatus(data)
    case 0x13:
      return calculateOxygenSensorsPresent(data)
    case 0x1C:
      return calculateDesignRequirements(data)
    case 0x1D:
      return "" //TODO: pid 29 - Oxygen Sensor
    case 0x1E:
      return calculateAuxiliaryInputStatus(data)
    default:
      return nil
    }
  }
  
  private func calculateAuxiliaryInputStatus(_ data : Data) -> String? {
    var dataA = data[0]
    dataA = dataA & ~0x7F // only bit 0 is valid
    
    if dataA & 0x01 != 0 {
      return "PTO_STATE: ON"
    }else if dataA & 0x02 != 0 {
      return "PTO_STATE: OFF"
    }else {
      return nil
    }
  }
  
  private func calculateDesignRequirements(_ data : Data) -> String? {
    var returnString : String?
    let dataA = data[0]
    
    switch dataA {
    case 0x01:
      returnString	= "OBD II"
      break
    case 0x02:
      returnString	= "OBD"
      break
    case 0x03:
      returnString	= "OBD I and OBD II"
      break
    case 0x04:
      returnString	= "OBD I"
      break
    case 0x05:
      returnString	= "NO OBD"
      break
    case 0x06:
      returnString	= "EOBD"
      break
    case 0x07:
      returnString	= "EOBD and OBD II"
      break
    case 0x08:
      returnString	= "EOBD and OBD"
      break
    case 0x09:
      returnString	= "EOBD, OBD and OBD II"
      break
    case 0x0A:
      returnString	= "JOBD";
      break
    case 0x0B:
      returnString	= "JOBD and OBD II"
      break
    case 0x0C:
      returnString	= "JOBD and EOBD"
      break
    case 0x0D:
      returnString	= "JOBD, EOBD, and OBD II"
      break
    default:
      returnString	= "N/A"
      break
    }
    
    return returnString
  }
  
  private func calculateOxygenSensorsPresent(_ data : Data) -> String {
    var returnString : String = ""
    let dataA = data[0]
    
    if dataA & 0x01 != 0 {
      returnString = "O2S11"
    }
    
    if dataA & 0x02 != 0 {
      returnString = "\(returnString), O2S12"
    }
    
    if dataA & 0x04 != 0 {
      returnString = "\(returnString), O2S13"
    }
    
    if dataA & 0x08 != 0 {
      returnString = "\(returnString), O2S14"
    }
    
    if dataA & 0x10 != 0 {
      returnString = "\(returnString), O2S21"
    }
    
    if dataA & 0x20 != 0 {
      returnString = "\(returnString), O2S22"
    }
    
    if dataA & 0x40 != 0 {
      returnString = "\(returnString), O2S23"
    }
    
    if dataA & 0x80 != 0 {
      returnString = "\(returnString), O2S24"
    }
    
    return returnString
  }
  
    private func calculateOxygenSensorsPresentB(_ data : Data) -> String {
        var returnString : String = ""
        let dataA = data[0]
        
        if(dataA & 0x01 != 0){
            returnString = "O2S11"
        }
        
        if dataA & 0x02 != 0 {
            returnString = "\(returnString), O2S12"
        }
        
        if dataA & 0x04 != 0 {
            returnString = "\(returnString), O2S21"
        }
        
        if(dataA & 0x08 != 0) {
            returnString = "\(returnString), O2S22"
        }
        
        if dataA & 0x10 != 0 {
            returnString = "\(returnString), O2S31"
        }
        
        if dataA & 0x20 != 0 {
            returnString = "\(returnString), O2S32"
        }
        
        if dataA & 0x40 != 0 {
            returnString = "\(returnString), O2S41"
        }
        
        if dataA & 0x80 != 0 {
            returnString = "\(returnString), O2S42"
        }
        
        return returnString
    }
  
  private func calculateFuelSystemStatus(_ data : Data) -> String {
    var rvString : String = ""
    let dataA = data[0]
    
    switch dataA {
    case 0x01:
      rvString		= "Open Loop"
      break
    case 0x02:
      rvString		= "Closed Loop"
      break
    case 0x04:
      rvString		= "OL-Drive"
      break;
    case 0x08:
      rvString		= "OL-Fault"
      break
    case 0x10:
      rvString		= "CL-Fault"
      break
    default:
      break
    }
    
    return rvString
  }
  
  private func calculateSecondaryAirStatus(_ data : Data) -> String {
    var rvString : String = ""
    let dataA = data[0]
    
    switch dataA {
    case 0x01:
      rvString		= "AIR_STAT: UPS"
      break
    case 0x02:
      rvString		= "AIR_STAT: DNS"
      break
    case 0x04:
      rvString		= "AIR_STAT: OFF"
      break
    default:
      break
    }
    
    return rvString
  }
}
