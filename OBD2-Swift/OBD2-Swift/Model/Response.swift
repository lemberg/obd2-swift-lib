//
//  Response.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public struct Response {
    var timestamp : Date
    var mode : Mode = .none
    var pid : UInt8 = 0
    var data : Data?
    
    init() {
        self.timestamp = Date()
    }
}
