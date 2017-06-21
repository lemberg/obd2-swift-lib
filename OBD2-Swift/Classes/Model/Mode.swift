//
//  Mode.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public enum Mode: RawRepresentable {
    
    public typealias RawValue = UInt8
    
    case none
    case CurrentData01
    case FreezeFrame02
    case DiagnosticTroubleCodes03
    case ResetTroubleCodes04
    case OxygenSensorMonitoringTestResults05 //CAN ONLY
    case RequestOnboardMonitoringTestResultsForSMS06 //CAN ONLY
    case DiagnosticTroubleCodesDetected07
    case ControlOfOnboardComponent08
    case RequestVehicleInfo09
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0x01:
            self = .CurrentData01
        case 0x02:
            self = .FreezeFrame02
        case 0x03:
            self = .DiagnosticTroubleCodes03
        case 0x04:
            self = .ResetTroubleCodes04
        case 0x05: //CAN ONLY
            self = .OxygenSensorMonitoringTestResults05
        case 0x06: //CAN ONLY
            self = .RequestOnboardMonitoringTestResultsForSMS06
        case 0x07:
            self = .DiagnosticTroubleCodesDetected07
        case 0x08:
            self = .ControlOfOnboardComponent08
        case 0x09:
            self = .RequestVehicleInfo09
        default:
            self = .none
        }
    }
    
    public var rawValue: UInt8 {
        switch self {
        case .CurrentData01:
            return 0x01
        case .FreezeFrame02:
            return 0x02
        case .DiagnosticTroubleCodes03:
            return 0x03
        case .ResetTroubleCodes04:
            return 0x04
        case .OxygenSensorMonitoringTestResults05:
            return 0x05
        case .RequestOnboardMonitoringTestResultsForSMS06:
            return 0x06
        case .DiagnosticTroubleCodesDetected07:
            return 0x07
        case .ControlOfOnboardComponent08:
            return 0x08
        case .RequestVehicleInfo09:
            return 0x09
        case .none:
            return 0x00
        }
    }
}
