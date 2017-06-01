//
//  Descriptor.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class Mode01Descriptor : DescriptorProtocol {
    var response : Response
    var descriptor : SensorDescriptor
    
    required init(describe response : Response) {
        self.response = response
        let pid = response.pid
        self.mode = Mode(rawValue: response.mode) ?? .none
        
        guard pid >= 0x0 && pid <= 0x4E else {
            assertionFailure("Unsuported pid group")
            self.descriptor = GlobalSensorDescriptorTable[0]
            return
        }
        self.descriptor = SensorDescriptorTable[Int(pid)]
    }
    
    var mode: Mode

    var pid : UInt8 {
        return response.pid
    }
    
    func isAlphaValue() -> Bool {
        return IS_ALPHA_VALUE(pid: pid)
    }
    
    func isMultiValue() -> Bool {
        return IS_MULTI_VALUE_SENSOR(pid: pid)
    }
    
    func valueForMeasurement(metric : Bool) -> Any? {
        guard let data = response.data else {
            return nil
        }
        
        if isAlphaValue() {
            return calculateStringForData(data: data)
        }
        
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
    
    //MARK: - String Calculation Methods
    
    func calculateStringForData(data : Data) -> String? {
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
