//
//  Descriptor03.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 5/25/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public class Mode03Descriptor : DescriptorProtocol {
  public var response : Response
  
  public required init(describe response : Response) {
    self.response = response
    self.mode = response.mode
  }
  
  public var mode : Mode
  
  private var pid: UInt8 {
    return response.pid
  }
  
  public func getTroubleCodes() -> [String] {
    guard let data = response.data , data.count >= 2 else {
      // data length must be a multiple of 2
      // each DTC is encoded in 2 bytes of data
      print("data \(String(describing: response.data)) is NULL or dataLength is not a multiple of 2 \(response.data?.count ?? 0)")
      return []
    }
    
    let systemCode: [Character]	= [ "P", "C", "B", "U" ]
    
    var codes = [String]()
    
    for i in 0..<data.count where i % 2 == 0 {
      let codeIndex = Int(data[i] >> 6)
      
      //Out of range
      guard codeIndex <= 4 else {break}
      
      let c1 = systemCode[codeIndex]
      let a2 = Int(data[i] & DTC_DIGIT_0_1_MASK)
      let a3 = Int(data[i+1] & DTC_DIGIT_2_3_MASK)
      
      let c2 = String(format: "%02d", a2)
      let c3 = String(format: "%02d", a3)
      
      let code = "\(c1)\(c2)\(c3)"
      
      codes.append(code)
      
      if (data.count - (i+2)) < 2 &&
        (data.count - (i+2)) % 2 != 0 {
        break
      }
    }
    
    return codes
  }
  
  public func isMILActive() -> Bool {
    return calcMILActive(data: response.rawData)
  }
  
  public func troubleCodeCount() -> Int {
    //   43 06 01 00 02 00
    //     [..] - 06 is a dct count.
    //Second byte of DCT response is a DTC count. Like a pid in other modes.
    return Int(self.pid)
  }
}
