//
//  Macros.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 08/06/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

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

func MORE_PIDS_SUPPORTED(_ data : [UInt8]) -> Bool {
  guard data.count > 3 else {return false}
  return ((data[3] & 1) != 0)
}

func NOT_SEARCH_PID(_ pid : Int) -> Bool {
  return (pid != 0x00 && pid != 0x20 &&
    pid != 0x40 && pid != 0x60 &&
    pid != 0x80 && pid != 0xA0 &&
    pid != 0xC0 && pid != 0xE0)
}


let kCarriageReturn = "\r"

let DTC_SYSTEM_MASK	: UInt8 = 0xC0
let DTC_DIGIT_0_1_MASK : UInt8 = 0x3F
let DTC_DIGIT_2_3_MASK : UInt8	= 0xFF
