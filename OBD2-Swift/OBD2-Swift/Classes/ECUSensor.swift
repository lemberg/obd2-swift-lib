//
//  ECUSensor.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 27/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


//
//  FLECUSensorCalculator.swift
//  OBD2-Swift-lib-example
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

//------------------------------------------------------------------------------
// Macros

// Macro to test if a given PID, when decoded, is an
// alphanumeric string instead of a numeric value
func IS_ALPHA_VALUE(pid : UInt8) -> Bool{
  return (pid == 0x03 || pid == 0x12 || pid == 0x13 || pid == 0x1C || pid == 0x1D || pid == 0x1E)
}

// Macro to test if a given PID has two measurements in the returned data
func IS_MULTI_VALUE_SENSOR(pid : UInt8)	-> Bool {
  return (pid >= 0x14 && pid <= 0x1B) ||
    (pid >= 0x24 && pid <= 0x2B) ||
    (pid >= 0x34 && pid <= 0x3B)
}


func IS_INT_VALUE(pid : Int8, sensor : OBD2Sensor) -> Bool	{
  return (pid >= 0x04 && pid <= 0x13) ||
    (pid >= 0x1F && pid <= 0x23) ||
    (pid >= 0x2C && pid <= 0x33) ||
    (pid >= 0x3C && pid <= 0x3F) ||
    (pid >= 0x43 && pid <= 0x4E) ||
    (pid >= 0x14 && pid <= 0x1B && sensor.rawValue == 0x02) ||
    (pid >= 0x24 && pid <= 0x2B && sensor.rawValue == 0x02) ||
    (pid >= 0x34 && pid <= 0x3B && sensor.rawValue == 0x02)
}




let DTC_SYSTEM_MASK	: UInt8 = 0xC0
let DTC_DIGIT_0_1_MASK : UInt8 = 0x3F
let DTC_DIGIT_2_3_MASK : UInt8	= 0xFF

//------------------------------------------------------------------------------
// Sensor
class ECUSensor {
  var currentResponse : ScanToolResponse?
  var pid : Int8?
  var data : Data?
  
  var descriptor : SensorDescriptor
  
  
  init(with descriptor : SensorDescriptor){
    self.descriptor = descriptor
  }
  
  var sensorValueHistory : [Any] = []
  var valueHistoryHead : Any? {
    return sensorValueHistory.first
  }
  var valueHistoryTail : Any? {
    return sensorValueHistory.last
  }
  
//  static func sensorForPID(pid : Int8) -> ECUSensor {
//    return ECUSensor(with: SensorDescriptor)
//  }
  
  static func sensorForPID(pid : UInt8) -> ECUSensor? {
    var sensor : ECUSensor?
    
    if pid >= 0x0 && pid <= 0x4E {
      sensor = ECUSensor(with: GlobalSensorDescriptorTable[Int(pid)])
    }
    
    return sensor
  }
  
  static func troubleCodesForResponse(response : ScanToolResponse) -> [String] {
    //(dataLength % 2) != 0) {
    // We have changed the dataLength check to allow for cases in
    // which an ECU returns a data stream that is not a multiple of 2.
    // Though technically an error condition, in real world testing this
    // appears to be more common than previously anticipated.
    // - mgile 08-Feb-2010
    
    guard let rData = response.data , rData.count >= 2 else {
      // data length must be a multiple of 2
      // each DTC is encoded in 2 bytes of data
      print("data \(String(describing: response.data)) is NULL or dataLength is not a multiple of 2 \(response.data?.count ?? 0)")
      return []
    }
    
    let systemCode : [Character]	= [ "P", "C", "B", "U" ]
    let asUInt8Array = String(systemCode).utf8.map{ UInt8($0) }
    
    let data = rData.withUnsafeBytes {
      [UInt8](UnsafeBufferPointer(start: $0, count: rData.count))
    }
    let dataLength = data.count
    var codes = [String]()
    
    for i in 0..<dataLength where i % 2 == 0 {
      let codeIndex = Int(data[i] & DTC_SYSTEM_MASK)
      let c1 = asUInt8Array[codeIndex]
      let c2 = Int(data[i] & DTC_DIGIT_0_1_MASK)
      let c3 = Int(data[i+1] & DTC_DIGIT_2_3_MASK)
      
      let code = "\(c1)\(c2)\(c3)"
      
      codes.append(code)
      
      if (dataLength - (i+2)) < 2 &&
        (dataLength - (i+2)) % 2 != 0 {
        break
      }
    }

    return codes
  }
  
  
  func isAlphaValue() -> Bool {
    guard let pid = self.pid else {
      return false
    }
    return IS_ALPHA_VALUE(pid: UInt8(pid))
  }
  
  func isMultiValue() -> Bool {
    guard let pid = self.pid else {
      return false
    }
    return IS_MULTI_VALUE_SENSOR(pid: UInt8(pid))
  }
  
  func isMILActive() -> Bool {
    //TODO: - 
    
//    guard let data = currentResponse?.data else {
//      return false
//    }
//    
//    let bytes = data.withUnsafeBytes {
//      [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
//    }
//    
//    if self.pid == 0x01 {
//      if calcMILActive([bytes], [bytes.count]) {
//        return true
//      }
//    }
//    
    return false
  }
  
  func troubleCodeCount() -> Int {
    //    guard let data = currentResponse?.data else {
    //      return false
    //    }
    //
    //    let bytes = data.withUnsafeBytes {
    //      [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
    //    }
    
//    if self.pid == 0x01 {
//      return calcNumTroubleCodes([data bytes], [data.count])
//    }
    
    return 0
  }
  
  func valueForMeasurement(metric : Bool) -> Any? {
    guard let data = currentResponse?.data else {
      return nil
    }

//    if isAlphaValue() {
//      return calculateStringForData(data)
//    }
    
    guard let exec = descriptor.calcFunction else {
      return nil
    }
    
    var val = exec(data)
    
    if metric {
      val = descriptor.convertFunction?(val) ?? val
    }
    
    return val
  }
  
  func valueStringForMeasurement(val : Any) -> String {
    return val as? String ?? String(describing: val as? Float) 
  }
  
  func unitStringForMeasurement(metric : Bool) -> String {
    return metric ? descriptor.metricUnit : descriptor.imperialUnit
  }
  
  func descriptionStringForMeasurement() -> String {
    return descriptor.description
  }
  
  func shortDescriptionStringForMeasurement() -> String {
    return descriptor.shortDescription
  }
  
  func minValueForMeasurement(metric : Bool) -> Int {
    if isAlphaValue() {
      return Int.min
    }
    
    return metric ? descriptor.minMetricValue : descriptor.minImperialValue
  }
  
  func maxValueForMeasurement(metric : Bool) -> Int {
    if isAlphaValue() {
      return Int.max
    }
    
    return metric ? descriptor.maxMetricValue : descriptor.maxImperialValue
  }
  
  //pragma mark String Calculation Methods
  
  func calculateStringForData(data : Data) -> String? {
    guard let pid = currentResponse?.pid  else {return nil}
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
      return ""
    case 0x1E:
      return calculateAuxiliaryInputStatus(data)
    default:
      return nil
    }
  }
  
  func calculateAuxiliaryInputStatus(_ data : Data) -> String? {
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
  
  func calculateDesignRequirements(_ data : Data) -> String? {
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
  
  func calculateOxygenSensorsPresent(_ data : Data) -> String {
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
  
  func calculateOxygenSensorsPresentB(_ data : Data) -> String {
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
  
  func calculateFuelSystemStatus(_ data : Data) -> String {
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
  
  func calculateSecondaryAirStatus(_ data : Data) -> String {
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
