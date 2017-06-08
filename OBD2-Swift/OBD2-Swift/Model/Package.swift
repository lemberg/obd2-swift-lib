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
    
    var isOK: Bool {
        return Parser.string.isOK(strigDescriptor)
    }
    
    var isError: Bool {
        return Parser.string.isError(strigDescriptor)
    }
    
    var isStopped: Bool	{
        return Parser.string.isStopped(strigDescriptor)
    }
    
    var isNoData: Bool {
        return Parser.string.isNoData(strigDescriptor)
    }
    
    var isSearching: Bool {
        return Parser.string.isSerching(strigDescriptor)
    }
    
    func isAuto(_ str : String) -> Bool {
        return Parser.string.isAuto(strigDescriptor)
    }
    
    var isData: Bool {
        return Parser.string.isDataResponse(strigDescriptor)
    }
    
    var isAT: Bool {
        return Parser.string.isATResponse(asciistr)
    }
    
    func isComplete() -> Bool {
        return Parser.string.isReadComplete(buffer)
    }
    
}
