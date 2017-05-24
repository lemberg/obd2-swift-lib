//
//  FLScanToolResponseParser.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 26/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

protocol ScanToolResponseParserDelegate {
  func parser( _ parser : ScanToolResponseParser, didReceiveResponse response : ScanToolResponse)
  func parser( _ parser : ScanToolResponseParser, didFailWithError response : NSError)
}


class ScanToolResponseParser {
  var	resolveLocation = false
  var bytes = [UInt8].init(repeating: 0, count: 512)
  var length = 0
  
  
  init(with bytes: [UInt8], length : Int){
    self.bytes = bytes
    self.length = length
  }
  
  func parseResponse(protocol : ScanToolProtocol) -> [ScanToolResponse] {
    //FIXME: -
    // Abstract method
    return []
  }
}
