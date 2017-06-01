//
//  ScanProtocol.swift
//  OBD2Swift
//
//  Created by Hellen Soloviy on 5/30/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

let elmProtocolMap: [ScanProtocol] = [
    .none,
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
    .none,
    .none
]

enum ScanProtocol: RawRepresentable {
    
    typealias RawValue = UInt16
    
    case none					//= 0x0000
    case ISO9141Keywords0808	//= 0x0001
    case ISO9141Keywords9494	//= 0x0002
    case KWP2000FastInit		//= 0x0004
    case KWP2000SlowInit		//= 0x0008
    case J1850PWM				//= 0x0010
    case J1850VPW				//= 0x0020
    case CAN11bit250KB          //= 0x0040
    case CAN11bit500KB          //= 0x0080
    case CAN29bit250KB          //= 0x0100
    case CAN29bit500KB          //= 0x0200
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case 0x0001:
            self = .ISO9141Keywords0808
        case 0x0002:
            self = .ISO9141Keywords9494
        case 0x0004:
            self = .KWP2000FastInit
        case 0x0008:
            self = .KWP2000SlowInit
        case 0x0010:
            self = .J1850PWM
        case 0x0020:
            self = .J1850VPW
        case 0x0040:
            self = .CAN11bit250KB
        case 0x0080:
            self = .CAN11bit500KB
        case 0x0100:
            self = .CAN29bit250KB
        case 0x0200:
            self = .CAN29bit500KB
        default:
            self = .none
        }
    }
    
    var rawValue: UInt16 {
        switch self {
        case .ISO9141Keywords0808:
            return 0x0001
        case .ISO9141Keywords9494:
            return 0x0002
        case .KWP2000FastInit:
            return 0x0004
        case .KWP2000SlowInit:
            return 0x0008
        case .J1850PWM:
            return 0x0010
        case .J1850VPW:
            return 0x0020
        case .CAN11bit250KB:
            return 0x0040
        case .CAN11bit500KB:
            return 0x0080
        case .CAN29bit250KB:
            return 0x0100
        case .CAN29bit500KB:
            return 0x0200
        case .none:
            return 0x0000
        }
    }
}
