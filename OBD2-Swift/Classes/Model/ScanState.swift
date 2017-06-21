//
//  ScanState.swift
//  OBD2Swift
//
//  Created by Hellen Soloviy on 5/30/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public enum ScanState {
    case none
    case openingConnection
    case initializing
    case connected
}

