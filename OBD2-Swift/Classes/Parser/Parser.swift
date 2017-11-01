//
//  Parser.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class Parser {
  static let string = StringParser()
  static let package = PackageReader()
  
  class StringParser {
    let kResponseFinishedCode : UInt8	=	0x3E
    
    func toInt(hexString str: String) -> Int {
      return Int(strtoul(str, nil, 16))
    }
    
    func toUInt8(hexString str: String) -> UInt {
      return strtoul(str, nil, 16)
    }
    
    func isReadComplete(_ buf: [UInt8]) -> Bool {
      return buf.last == kResponseFinishedCode
    }
    
    func isOK(_ str: String) -> Bool{
      return str.contains("OK")
    }
    
    func isError(_ str: String) -> Bool {
      return str.contains("?")
    }
    
    func isNoData(_ str: String) -> Bool {
      return str.contains("NO DATA")
    }
    
    func isStopped(_ str: String)	-> Bool	{
      return str.contains("STOPPED")
    }
    
    func isSerching(_ str: String)	-> Bool	{
      return str.contains("SEARCHING...")
    }
    
    func isAuto(_ str : String)     -> Bool {
      return str.hasPrefix("AUTO")
    }
    
    func isDataResponse(_ str : String)	-> Bool	{
      let unwrapStr = str.first ?? Character.init("")
      let str = String(describing: unwrapStr)
      let isDigit = Int(str) != nil
      return isDigit // || isSerching(str)
    }
    
    func isATResponse(_ str : [Int8])	-> Bool	{
      guard let char = str.first else { return false }
      guard let int32 = Int32.init(exactly: char) else { return false }
      return isalpha(int32) == 0
    }
        
    func getProtocol(fro index: Int8) -> ScanProtocol {
      let i = Int(index)
      return elmProtocolMap[i]
    }
    
    func protocolName(`protocol`: ScanProtocol) -> String {
      switch `protocol` {
      case .ISO9141Keywords0808:
        return "ISO 9141-2 Keywords 0808"
      case .ISO9141Keywords9494:
        return "ISO 9141-2 Keywords 9494"
      case .KWP2000FastInit:
        return "KWP2000 Fast Init"
      case .KWP2000SlowInit:
        return "KWP2000 Slow Init"
      case .J1850PWM:
        return "J1850 PWM"
      case .J1850VPW:
        return "J1850 VPW"
      case .CAN11bit250KB:
        return "CAN 11-Bit 250Kbps"
      case .CAN11bit500KB:
        return "CAN 11-Bit 500Kbps"
      case .CAN29bit250KB:
        return "CAN 29-Bit 250Kbps"
      case .CAN29bit500KB:
        return "CAN 29-Bit 500Kbps"
      case .none:
        return"Unknown Protocol"
      }
    }
  }
  
  //Parsing command response
  class PackageReader {
    func read(package: Package) -> Response {
      return parseResponse(package: package)
    }
    
    private func optimize(package: inout Package){
      while package.buffer.last == 0x00 || package.buffer.last == 0x20 {
        package.buffer.removeLast()
      }
    }
    
    private func compress(components: inout [String], outputSize: inout Int){
      for (i,s) in components.enumerated() {
        components[i] = s.replacingOccurrences(of: (i - 1).description  + ":", with: "")
      }
      
      /* Mode $01 PID $00 request makes multiple chunks value w/o data size description.
         Data size over 3 length like "41 00 BE 1B 30 13" could not be size descriptor
         Size descriptor : 00E become 0x0E => 14 (Int)
       */
      if components.first?.count ?? 0 <= 4 {
        let headByteSyzeString = components.removeFirst()
        outputSize = Parser.string.toInt(hexString: headByteSyzeString)
      }
    }
    
    private func parseResponse(package p : Package) -> Response {
      var package = p
      optimize(package: &package)
      
      var response = Response()
      
      if !package.isError && package.isData {
        var responseComponents = package.strigDescriptor.components(separatedBy: "\r")
        
        var decodeBufLength = 0
        var decodeBuf = [UInt8]()
        
        //Remove package descriptors from array
        if responseComponents.count > 2 {
          compress(components : &responseComponents, outputSize : &decodeBufLength)
        }
        
        for resp in responseComponents {
          if Parser.string.isSerching(resp) && Parser.string.isStopped(resp){
            // A common reply if PID search occuring for the first time
            // at this drive cycle
            break
          }
          
          // make byte array from string response
          let chunks = resp.components(separatedBy: " ").filter({$0 != ""})

          for c in chunks {
            let value = Parser.string.toUInt8(hexString: c)
            decodeBuf.append(UInt8(value))
          }
        }//TODO: - Handle negative
        
        if decodeBufLength == 0 {
          decodeBufLength = decodeBuf.count
        }else{
          decodeBufLength = min(decodeBufLength, decodeBuf.count)
          decodeBuf.removeSubrange(decodeBufLength..<decodeBuf.count)
        }

        response = decode(data: decodeBuf, length: decodeBufLength)
      }else{
        response.strigDescriptor = package.strigDescriptor
      }
      
      response.rawData = package.buffer
      
      return response
    }
    
    func decode(data : [UInt8], length : Int) -> Response {
      var resp = Response()
      var dataIndex = 0

      let modeRaw   = data[dataIndex] ^ 0x40
      resp.mode     = Mode.init(rawValue: modeRaw) ?? .none
      dataIndex     += 1
      
      if data.count > dataIndex {
        resp.pid		= data[dataIndex]
        dataIndex   += 1
      }
      
      //Byte shift specialy for freezeframe data
      // 42 0C 00 4E 20
      // 42 - Mode
      // 0C - Pid
      // 00 - Shifted
      // 4E 20 - Data equal to mode 1.
      if resp.mode == .FreezeFrame02 {
        dataIndex   += 1
      }
      
      if data.count > dataIndex {
        var mutatingData = data
        mutatingData.removeSubrange(0..<dataIndex)
        
        resp.data	  = Data.init(bytes: mutatingData, count: length - dataIndex)
      }
      
      return resp
    }
  }
}
