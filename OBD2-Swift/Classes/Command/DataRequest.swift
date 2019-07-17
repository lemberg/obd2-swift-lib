//
//  Command.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public class DataRequest {
    
    var description:String
    
    init(from string: String) {
        self.description = string
    }
    
    convenience init(mode : Mode, pid : UInt8, param : String? = nil) {
        var description = ""
        
        if pid >= 0x00 && pid <= 0x4E {
            description = NSString.init(format: "%02lx %02lx", mode.rawValue, pid) as String
            
            //Additional for freeze frame request
            // 020C00 instead of 020C
            if mode == .FreezeFrame02 {
                description += "00"
            }
        }else {
            description = NSString.init(format: "%02lx", mode.rawValue) as String
        }
        
        if let param = param {
            description += (" " + param)
        }
        
        self.init(from: description)
    }
    
    lazy var data: Data? = {
        let dataDescription = "\(self.description)\(kCarriageReturn)"
        return dataDescription.data(using: .ascii)
    }()
}

extension DataRequest: Equatable {
    
    public static func ==(lhs: DataRequest, rhs: DataRequest) -> Bool {
        return lhs.description == rhs.description
    }
}

extension DataRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description.hash)
    }
}
