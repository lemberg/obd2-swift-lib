//
//  DescriptorProtocol.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

protocol DescriptorProtocol {
    var response : Response {get set}
    var mode : Mode {get}
    init(describe response : Response)
}
