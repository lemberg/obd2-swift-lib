//
//  ScanToolState.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum ScanToolState {
  case STATE_INIT
  case STATE_IDLE
  case STATE_WAITING
  case STATE_PROCESSING
  case STATE_ERROR
  case NUM_STATES
}


enum ScanToolDeviceType{
  case BluTrax
  case ELM327
  case OBDKey
  case GoLink
  case Simulated
}

enum ScanToolMode : UInt8 {
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

enum ScanToolProtocol : Int16 {
  case None					= 0x0000
  case ISO9141Keywords0808	= 0x0001
  case ISO9141Keywords9494	= 0x0002
  case KWP2000FastInit		= 0x0004
  case KWP2000SlowInit		= 0x0008
  case J1850PWM				= 0x0010
  case J1850VPW				= 0x0020
  case CAN11bit250KB			= 0x0040
  case CAN11bit500KB			= 0x0080
  case CAN29bit250KB			= 0x0100
  case CAN29bit500KB			= 0x0200
}
