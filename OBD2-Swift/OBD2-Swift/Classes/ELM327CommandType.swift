//
//  ELM327CommandType.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 26/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum ELM327CommandType : UInt8 {
  case ELM327ATCommand				= 0x01
  case ELM327OBDCommand				= 0x02
}
