//
//  ELM327ResponseParser.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 26/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class ELM327ResponseParser : ScanToolResponseParser {
  var decodeBufLength = 0
  var decodeBuf = [UInt8]()
  
  var stringForResponse : String {
    /*
     const char* test = "41 00 90 18 80 00 \r41 00 BF 9F F9 91 ";
     return [NSString stringWithCString:test encoding:NSASCIIStringEncoding];
     */
    
    let asciistr = bytes.map({Int8.init(bitPattern: $0)})
    let respString = String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
    
    return respString
  }
  
  func CLEAR_DECODE_BUF(){
    memset(&bytes, 0x00, length)
    length = 0
  }
  
  override func parseResponse(protocol: ScanToolProtocol) -> [ScanToolResponse] {
    var responseArray = [ScanToolResponse]()
    
    /*
     TODO:
     
     41 00 BF 9F F9 91 41 00 90 18 80 00
     
     Deal with cases where the ELM327 does not properly insert a CR in between
     a multi-ECU response packet (real-world example above - Mode $01 PID $00).
     
     Need to split on modulo 6 boundary and check to ensure total packet length
     is a multiple of 6.  If not, we'll have to discard.
     
     */
    
    
    // Chop off the trailing space, if it's there
    if bytes[length-1] == 0x20 {
       bytes[length-1] = 0x00
       length-=1
    }
    
    let respString = stringForResponse
    
    if !ELM_ERROR(respString) && ELM_DATA_RESPONSE(respString) {
      
      // There may be more than one response, if multiple ECUs responded to
      // a particular query, so split on the '\r' boundary
      let responseComponents = respString.components(separatedBy: "\r")
      
      for resp in responseComponents {
        CLEAR_DECODE_BUF()
        
        if ELM_SEARCHING(resp) {
          // A common reply if PID search occuring for the first time
          // at this drive cycle
          break;
        }
        
        // For each response data string, decode into an integer array for
        // easier processing
        
        let chunks = respString.components(separatedBy: " ")
        
        for c in chunks {
          let value = Int(strtoul(c, nil, 16))
          decodeBuf.append(UInt8(value))
          decodeBufLength += 1
        }

        let obj = decodeResponseData(data: decodeBuf, length: decodeBufLength, protocol: `protocol`)
        responseArray.append(obj)
      }
    }else {
      print("Error in parse string or non-data response: \(respString)")
    }
    
    return responseArray
  }
  
  func decodeResponseData(data : [UInt8], length : Int, `protocol`: ScanToolProtocol) -> ScanToolResponse {
    let resp = ScanToolResponse()
    var dataIndex = 0
    
    resp.scanToolName		= "ELM327";
    resp.`protocol`         = `protocol`
    resp.responseData		= Data.init(bytes: data, count: length)
    resp.mode               = (data[dataIndex] ^ 0x40)
    dataIndex += 1
    
    if resp.mode == ScanToolMode.RequestCurrentPowertrainDiagnosticData.rawValue {
      resp.pid			= data[dataIndex]
      dataIndex += 1
    }
    
    if(length > 2) {
      resp.data	= Data.init(bytes: [data[dataIndex]], count: length-dataIndex)
    }
    
    return resp
  }
}
