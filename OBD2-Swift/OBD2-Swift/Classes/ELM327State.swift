//
//  ELM327State.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum ELM327InitState : UInt16 {
  case UNKNOWN			= 0x0000
  case RESET				= 0x0001
  case ECHO_OFF			= 0x0002
  case VERSION			= 0x0004
  case SEARCH		= 0x0008
  case PROTOCOL			= 0x0010
  case COMPLETE			= 0x0020
  
  static var all : [ELM327InitState] {
    return [.UNKNOWN, .RESET, .ECHO_OFF, .VERSION, .SEARCH, .PROTOCOL, .COMPLETE]
  }
  
  static func <<= (left: ELM327InitState, right: UInt16) -> ELM327InitState {
    let move = left.rawValue << right
    return self.all.filter({$0.rawValue == move}).first ?? .UNKNOWN
  }
}


/*
 These are the protocol numbers for the ELM327:
 
 0 - Automatic
 1 - SAE J1850 PWM (41.6 Kbaud)
 2 - SAE J1850 VPW (10.4 Kbaud)
 3 - ISO 9141-2  (5 baud init, 10.4 Kbaud)
 4 - ISO 14230-4 KWP (5 baud init, 10.4 Kbaud)
 5 - ISO 14230-4 KWP (fast init, 10.4 Kbaud)
 6 - ISO 15765-4 CAN (11 bit ID, 500 Kbaud)
 7 - ISO 15765-4 CAN (29 bit ID, 500 Kbaud)
 8 - ISO 15765-4 CAN (11 bit ID, 250 Kbaud)
 9 - ISO 15765-4 CAN (29 bit ID, 250 Kbaud)
 A - SAE J1939 CAN (29 bit ID, 250* Kbaud)
 B - USER1 CAN (11* bit ID, 125* Kbaud)
 C - USER2 CAN (11* bit ID, 50* Kbaud)
 
 
 We map these back to our base protocol list, which is itself derived from
 the BluTrax protocol-to-number mapping
 */

enum ELM327Protocol {
  case Automatic
  case SAEJ1850PWM
  case SAEJ1850VPW
  case ISO9141
  case ISO14230KWP
  case ISO14230KWPFastInit
  case ISO15765CAN11Bit500
  case ISO15765CAN29Bit500
  case ISO15765CAN11Bit250
  case ISO15765CAN29Bit250
  case SAEJ1939CAN29Bit250
  case User1CAN11Bit125
  case User2CAN11Bit50
}

let elm_protocol_map : [ScanToolProtocol] = [
  .None,
  .J1850PWM,
  .J1850VPW,
  .ISO9141Keywords0808,
  .KWP2000SlowInit,
  .KWP2000FastInit,
  .CAN11bit500KB,
  .CAN29bit500KB,
  .CAN11bit250KB,
  .CAN29bit250KB,
  .CAN29bit250KB,
  .None,
  .None
]
