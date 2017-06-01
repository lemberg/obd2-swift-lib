//
//  Descriptor03.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class Mode03Descriptor: DescriptorProtocol {
    var response: Response
    
    required init(describe response: Response) {
        self.response = response
        self.mode = Mode(rawValue: response.mode) ?? .none
    }
    
    var mode: Mode
    
    var pid: UInt8 {
        return response.pid
    }
    
    func getTroubleCodes() -> [String] {        
        guard let rData = response.data, rData.count >= 2 else {
            // data length must be a multiple of 2
            // each DTC is encoded in 2 bytes of data
            print("data \(String(describing: response.data)) is NULL or dataLength is not a multiple of 2 \(response.data?.count ?? 0)")
            return []
        }
        
        let systemCode: [Character]	= [ "P", "C", "B", "U" ]
        let asUInt8Array = String(systemCode).utf8.map{ UInt8($0) }
        
        let data = rData.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: rData.count))
        }
        let dataLength = data.count
        var codes = [String]()
        
        for i in 0..<dataLength where i % 2 == 0 {
            let codeIndex = Int(data[i] & DTC_SYSTEM_MASK)
            let c1 = asUInt8Array[codeIndex]
            let c2 = Int(data[i] & DTC_DIGIT_0_1_MASK)
            let c3 = Int(data[i+1] & DTC_DIGIT_2_3_MASK)
            
            let code = "\(c1)\(c2)\(c3)"
            
            codes.append(code)
            
            if (dataLength - (i+2)) < 2 &&
                (dataLength - (i+2)) % 2 != 0 {
                break
            }
        }
        
        return codes
    }
    
    
    func isAlphaValue() -> Bool {
        return IS_ALPHA_VALUE(pid: pid)
    }
    
    func isMultiValue() -> Bool {
        return IS_MULTI_VALUE_SENSOR(pid: pid)
    }
    
    func isMILActive() -> Bool {
        guard let data = response.data else {
            return false
        }
        
        if self.pid == 0x01 {
            return calcMILActive(data: data)
        }
        
        return false
    }
    
    func troubleCodeCount() -> Int {
        guard let data = response.data else {
            return 0
        }

        if self.pid == 0x01 {
            return calcNumTroubleCodes(data: data)
        }
        
        return 0
    }
}
