//
//  Mode.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum Mode : UInt8 {
    case RequestCurrentPowertrainDiagnosticData = 0x01
    case RequestPowertrainFreezeFrameData = 0x02
    case RequestEmissionRelatedDiagnosticTroubleCodes = 0x03
    case ClearResetEmissionRelatedDiagnosticInfo = 0x04
    case RequestOxygenSensorMonitoringTestResults = 0x05
    case RequestOnboardMonitoringTestResultsForSMS = 0x06
    case RequestEmissionRelatedDiagnosticTroubleCodesDetected = 0x07
    case RequestControlOfOnboardSystemTestOrComponent = 0x08
    case RequestVehicleInfo = 0x09
}
