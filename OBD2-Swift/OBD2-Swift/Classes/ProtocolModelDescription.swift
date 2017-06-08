//
//  ResponseType.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 26/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


///-------------------------------------------

protocol NonCanResponseProtocol {
  var	priority : UInt8 {get set}
  var	targetAddress : UInt8 {get set}
  var	ecuAddress : UInt8 {get set}
  var	mode : UInt8 {get set}
  var	pid : UInt8 {get set}
  var	dataBytes : [UInt8] {get set}
}

struct J1850PWMResponse : NonCanResponseProtocol {
  var	priority : UInt8
  var	targetAddress : UInt8
  var	ecuAddress : UInt8
  var	mode : UInt8
  var	pid : UInt8
  var	dataBytes : [UInt8]
}


struct J1850VPWResponse : NonCanResponseProtocol {
  var	priority : UInt8
  var	targetAddress : UInt8
  var	ecuAddress : UInt8
  var	mode : UInt8
  var	pid : UInt8
  var	dataBytes : [UInt8]
}


struct KWP2000Response : NonCanResponseProtocol {
  var	priority : UInt8
  var	targetAddress : UInt8
  var	ecuAddress : UInt8
  var	mode : UInt8
  var	pid : UInt8
  var	dataBytes : [UInt8]
}

struct ISO9141Response : NonCanResponseProtocol {
  var	priority : UInt8
  var	targetAddress : UInt8
  var	ecuAddress : UInt8
  var	mode : UInt8
  var	pid : UInt8
  var	dataBytes : [UInt8]
}


///-------------------------------------------

protocol Can11bitResponseProtocol {
  var	header1 : UInt8 {get set}
  var	header2 : UInt8 {get set}
  var	PCI : UInt8 {get set}
  var	mode : UInt8 {get set}
  var	dataBytes : [UInt8] {get set}
}

struct CAN11bitResponse : Can11bitResponseProtocol {
  var	header1 : UInt8
  var	header2 : UInt8
  var	PCI : UInt8
  var	mode : UInt8
  var	dataBytes : [UInt8]
}

///-------------------------------------------

protocol Can29BitResponseProtocol : Can11bitResponseProtocol {
  var	destinationAddress : UInt8 {get set}
  var	sourceAddress : UInt8 {get set}
  var	pid : UInt8 {get set}
}

struct CAN29BitResponse : Can29BitResponseProtocol {
  var	header1 : UInt8
  var	header2 : UInt8
  var	PCI : UInt8
  var	mode : UInt8
  var	dataBytes : [UInt8]
  var	destinationAddress : UInt8
  var	sourceAddress : UInt8
  var	pid : UInt8
}
