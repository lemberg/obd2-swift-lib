//
//  Command.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public class Command {
  var description = ""
  
  init(from string: String) {
    self.description = string
  }
  
  convenience init(mode : Mode, pid : UInt8, param : String? = nil) {
    var description = ""
    
    if pid >= 0x00 && pid <= 0x4E {
      description = NSString.init(format: "%02lx %02lx", mode.rawValue, pid) as String
    }else {
      description = NSString.init(format: "%02lx", mode.rawValue) as String
    }
    
    if let param = param {
      description += (" " + param)
    }
    
    self.init(from: description)
  }
  
  func getData() -> Data? {
    description.append(kCarriageReturn)
    return description.data(using: .ascii)
  }
    
}
