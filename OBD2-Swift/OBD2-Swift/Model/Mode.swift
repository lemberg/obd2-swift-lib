//
//  Mode.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum Mode : UInt8 {
    case CurrentData01 = 0x01
    case FreezeFrame02 = 0x02
    case DiagnosticTroubleCodes03 = 0x03
    case ResetTroubleCodes04 = 0x04
    case OxygenSensorMonitoringTestResults05 = 0x05 //CAN ONLY
    case RequestOnboardMonitoringTestResultsForSMS06 = 0x06 //CAN ONLY
    case DiagnosticTroubleCodesDetected07 = 0x07
    case ControlOfOnboardComponent08 = 0x08
    case RequestVehicleInfo09 = 0x09
}
