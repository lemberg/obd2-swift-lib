//
//  ScanToolCommand.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class ScanToolCommand {
  var mode : UInt8 = 0
  var pid : UInt8 = 0
  var data : Data?
}
