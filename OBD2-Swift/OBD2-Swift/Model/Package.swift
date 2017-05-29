//
//  Package.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

struct Package {
    
    var buffer: [UInt8]
    var length: Int
    
    init(buffer : [UInt8], length : Int) {
        self.buffer = buffer
        self.length = length
    }
    
    /*
     const char* test = "41 00 90 18 80 00 \r41 00 BF 9F F9 91 ";
     return [NSString stringWithCString:test encoding:NSASCIIStringEncoding];
     */
    var asciistr: [Int8] {
        return ascii()
    }
    
    var strigDescriptor: String {
        return String(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
    }
    
    private func ascii() -> [Int8] {
        return buffer.map({Int8.init(bitPattern: $0)})
    }
    
    
    var isOK: Bool{
        return strigDescriptor.contains("OK")
    }
    
    var isError: Bool {
        return strigDescriptor.contains("?")
    }
    
    var isStopped: Bool	{
        return strigDescriptor.contains("STOPPED")
    }
    
    var isNoData: Bool {
        return strigDescriptor.contains("NO DATA")
    }
    
    var isSearching: Bool {
        return strigDescriptor.contains("SEARCHING...")
    }
    
    func isAuto(_ str : String) -> Bool {
        return strigDescriptor.hasPrefix("AUTO")
    }
    
    var isData: Bool {
        let unwrapStr = strigDescriptor.characters.first ?? Character(" ")
        let str = String(describing: unwrapStr)
        let isDigit = Int(str) != nil
        return isDigit
    }
    
    var isAT: Bool {
        guard let char = asciistr.first else { return false }
        guard let int32 = Int32(exactly: char) else { return false }
        return isalpha(int32) == 0
    }
    
    func isComplete() -> Bool {
        return buffer.last == kResponseFinishedCode
    }
}
