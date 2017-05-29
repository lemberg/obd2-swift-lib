//
//  SimScanTool.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation
//
//@interface ELM327 (Private)
//- (FLScanToolCommand*) commandForInitState:(ELM327InitState)state;
//- (void) handleInputEvent:(NSStreamEvent)eventCode;
//- (void) handleOutputEvent:(NSStreamEvent)eventCode;
//- (void) readInput;
//- (void) readInitResponse;
//- (void) readVoltageResponse;
//@end


//MARK:- implementation ELM327
let kResponseFinishedCode : UInt8	=	0x3E

func INIT_COMPLETE(_ state : ELM327InitState) -> Bool {
  return state == .COMPLETE
}

func ELM_READ_COMPLETE(_ buf : [UInt8]) -> Bool {
  return buf.last == kResponseFinishedCode
}

func ELM_OK(_ str : String)             -> Bool{
  return str.contains("OK")
}

func ELM_ERROR(_ str : String)          -> Bool	{
  return str.contains("?")
}

func ELM_NO_DATA(_ str : String)        -> Bool	{
  return str.contains("NO DATA")
}

func ELM_SEARCHING(_ str : String)      -> Bool	{
  return str.contains("SEARCHING...")
}

func ELM_DATA_RESPONSE(_ str : String)	-> Bool	{
  let unwrapStr = str.characters.first ?? Character.init("")
  let str = String(describing: unwrapStr)
  let isDigit = Int(str) != nil
  return isDigit || ELM_SEARCHING(str)
}

func ELM_AT_RESPONSE(_ str : [Int8])	-> Bool	{
  guard let char = str.first else {return false}
  guard let int32 = Int32.init(exactly: char) else {return false}
  return isalpha(int32) == 0
}

func GET_PROTOCOL(elm_proto : Int8) -> ScanToolProtocol {
  let index = Int(elm_proto)
  return elm_protocol_map[index]
}


open class ELM327 : WifiScanTool {
  var initState : ELM327InitState = .UNKNOWN
  var parser : ELM327ResponseParser!
  var initOperations = [Any]()
  var maxSize = 512
  var readBuf = [UInt8](repeating: 0, count: 512)
  var readBufLength = 0
  
  convenience public init(host : String, port : Int) {
    self.init()
    self.host = host
    self.port = port
  }
  
  override init() {
    super.init()
    deviceType = .GoLink
    scanToolName = "ELM327"
  }
  
  func CLEAR_READBUF(){
    readBufLength = 0
    memset(&readBuf, 0x00, readBuf.count)
  }
  
  func commandForInitState(state : ELM327InitState) -> ScanToolCommand? {
    var cmd : ScanToolCommand?
    switch (state) {
    case .RESET:
      cmd = ELM327Command.commandForReset
      break
    case .ECHO_OFF:
      cmd = ELM327Command.commandForEchoOff
      break
    case .PROTOCOL:
      cmd = ELM327Command.commandForReadProtocol
      break
    case .VERSION:
      cmd = ELM327Command.commandForReadVersionID
      break
      
    case .SEARCH:
      
      cmd = ELM327Command.commandForOBD2(mode: .RequestCurrentPowertrainDiagnosticData,
        pid: currentPIDGroup,
        data:nil)
      break
    default:
      break
    }
    
    return cmd
  }
  
  override func initScanTool(){
    CLEAR_READBUF()
    
    state				= .STATE_INIT
    initState			= .RESET
    currentPIDGroup     = 0x00
    
    while inputStream.streamStatus != Stream.Status.open && outputStream.streamStatus != Stream.Status.open {
      
    }
    
    self.sendCommand(command: ELM327Command.commandForReset , initCommand: true)
  }
  
  func readInitResponse() {
    let readLength = inputStream.read(&readBuf, maxLength: maxSize)
    guard readLength > 0 else {return}
    var buff = readBuf
    buff.removeSubrange(readLength..<maxSize)
    readBufLength = readLength
    
    if ELM_READ_COMPLETE(buff) {
      if (readBufLength - 3) > 0 && (readBufLength - 3) < buff.count {
        buff[(readBufLength - 3)] = 0x00
        readBufLength	-= 3
      }

      
      let asciistr : [Int8] = buff.map({Int8.init(bitPattern: $0)})
      let respString = String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
      print(respString)
      
      if ELM_ERROR(respString) {
        initState	= .RESET
        state	= .STATE_INIT
      }else{
        switch initState {
        case .RESET:
          initState = initState <<= 1
          delegate?.scanToolDidConnect(scanTool: self)
          break
        case .ECHO_OFF:
          if !ELM_OK(respString) {
            print("Error response from ELM327 during Echo Off: \(String(describing: respString))")
          }else {
            initState = initState <<= 1
          }
          break
        case .PROTOCOL:
          var searchIndex = 0
          if respString.hasPrefix("AUTO") {
            // The 'A' is for Automatic.  The actual
            // protocol number is at location 1, so
            // increment pointer by 1
            //asciistr += 1
            searchIndex += 1
          }

          let index =  asciistr[searchIndex] - 0x4E
          `protocol` = GET_PROTOCOL(elm_proto: index)
          
          if `protocol` != .none {
            initState = initState <<= 1
          }
          
          break
          
        case .VERSION:
          initState = initState <<= 1
          break
        case .SEARCH:
          
          if ELM_ERROR(respString) {
            print("Error response from ELM327 during PID search (state=\(initState)): \(String(describing: respString))")
            initState = .RESET
          }else {
            if let parser = parser {
              parser.bytes = buff
              parser.length = readBufLength
            }else{
              parser = ELM327ResponseParser(with: buff, length: readBufLength)
            }
            
            let responses = parser.parseResponse(protocol: .none)
            var extendPIDSearch	= false
            
            for resp in responses {
              let morePIDs = buildSupportedSensorList(data: resp.data!, pidGroup: Int(currentPIDGroup))
              
              if !extendPIDSearch && morePIDs {
                extendPIDSearch	= true
              }
              
              print("More PIDs: \(morePIDs ? "YES" : "NO")")
            }
            
            currentPIDGroup	+= extendPIDSearch ? 0x20 : 0x00
            
            if extendPIDSearch {
              if currentPIDGroup > 0x40 {
                initState	= initState <<= 1
                currentPIDGroup	= 0x00
              }
            }else{
              initState	= initState <<= 1
              currentPIDGroup	= 0x00
            }
          }
          break
        default:
          break
        }
        
        CLEAR_READBUF()
        
        if INIT_COMPLETE(initState) {
          print("Init Complete")
          initState	= .UNKNOWN
          state	= .STATE_IDLE;
          delegate?.scanToolDidInitialize(scanTool: self)
          
          //TODO: -
          //FIXME: -
          setSensorScanTargets(targets: [0x0C, 0x0D])
        }else {
          if let cmd = commandForInitState(state: initState) {
            sendCommand(command: cmd, initCommand: true)
          }
        }
      }
    }
  }
  
  func readInput(){
    let readLength = inputStream.read(&readBuf, maxLength: maxSize)
    guard readLength > 0 else {return}
    var buff = readBuf
    buff.removeSubrange(readLength..<maxSize)
    
    readBufLength = readLength
    
    if ELM_READ_COMPLETE(buff) {
      if (readBufLength - 3) > 0 && (readBufLength - 3) < buff.count {
        buff[(readBufLength - 3)] = 0x00
        readBufLength	-= 3
      }

      let asciistr : [Int8] = buff.map({Int8.init(bitPattern: $0)})
      let respString = String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
      print(respString)
      
      if ELM_ERROR(respString) {
        initState	= .RESET
        state	= .STATE_INIT
      }else{
        if let parser = parser {
          parser.bytes = buff
          parser.length = readBufLength
        }else{
          parser = ELM327ResponseParser(with: buff, length: readBufLength)
        }
        
        let responses	= parser.parseResponse(protocol: `protocol`)
        
        self.didReceiveResponses(responses: responses)
        
        delegate?.didReceiveResponse(scanTool: self, responses: responses)
        
        state = .STATE_IDLE
        
        if let cmd = dequeueCommand() {
          sendCommand(command: cmd , initCommand: true)
        }
      }
    }else{
      state = .STATE_WAITING
    }
    
    if state == .STATE_IDLE || state == .STATE_INIT {
      CLEAR_READBUF()
    }
  }
  
  func readVoltageResponse(){
    let readLength = inputStream.read(&readBuf, maxLength: readBufLength)
    guard readLength > 0 else {return}
    var buff = readBuf
    buff.removeSubrange(readLength..<maxSize)
    
    readBufLength = readLength

    if ELM_READ_COMPLETE(buff) {
      state			= .STATE_PROCESSING
      
      if (readBufLength - 3) > 0 && (readBufLength - 3) < buff.count {
        buff[(readBufLength - 3)] = 0x00
        readBufLength	-= 3
      }
      
      let asciistr : [Int8] = buff.map({Int8.init(bitPattern: $0)})
      let respString = String.init(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
      print(respString)
      
      if ELM_ERROR(respString) {
        initState	= .RESET
        state	= .STATE_INIT
      }else{
        delegate?.didReceiveVoltage(scanTool: self, voltage: respString)
        state = .STATE_IDLE
        
        if let cmd = dequeueCommand() {
          sendCommand(command: cmd , initCommand: true)
        }
      }
    }else{
      state = .STATE_WAITING
    }
    
    if state == .STATE_IDLE || state == .STATE_INIT {
      CLEAR_READBUF()
      waitingForVoltageCommand	= false
    }
  }
  
  //MARK:- NSStream Event Handling Methods
  override func stream(stream : Stream, handleEvent eventCode : Stream.Event) {
    if stream == inputStream {
      handleInputEvent(eventCode)
    }else if stream == outputStream {
      handleOutputEvent(eventCode)
    }else {
      print("Received event for unknown stream")
    }
  }
  
  func handleInputEvent(_ eventCode : Stream.Event){
    if eventCode == .openCompleted {
      print("NSStreamEventOpenCompleted")
    }else if eventCode == .hasBytesAvailable {
      print("NSStreamEventHasBytesAvailable")
      
      if state == .STATE_INIT {
        readInitResponse()
      }else if state == .STATE_IDLE || state == .STATE_WAITING {
        waitingForVoltageCommand ? readVoltageResponse() : readInput()
      }else {
        print("Received bytes in unknown state: \(state)")
      }
    }else if eventCode == .errorOccurred {
      print("NSStreamEventErrorOccurred")
      
      if let error = inputStream.streamError {
        print(error.localizedDescription)
        delegate?.didReceiveError(scanTool: self, error: error)
      }
    }
  }
  
  func handleOutputEvent(_ eventCode : Stream.Event){
    if eventCode == .openCompleted {
      print("NSStreamEventOpenCompleted")
    }else if eventCode == .hasSpaceAvailable {
      print("NSStreamEventHasBytesAvailable")
      writeCachedData()
    }else if eventCode == .errorOccurred {
      print("NSStreamEventErrorOccurred")
      if let error = inputStream.streamError {
        print(error.localizedDescription)
      }
    }
  }
  
  //MARK: - ScanToolCommand Generators
  override func commandForGenericOBD(mode: ScanToolMode, pid: UInt8, data: Data?) -> ScanToolCommand {
    return ELM327Command.commandForOBD2(mode: mode, pid: pid , data: data)
  }

  override func commandForReadVersionNumber() -> ScanToolCommand {
    return ELM327Command.commandForReadVersionID
  }
  
  override func commandForReadProtocol() -> ScanToolCommand {
    return ELM327Command.commandForReadProtocol
  }
  
  override func commandForGetBatteryVoltage() -> ScanToolCommand {
    return ELM327Command.commandForReadVoltage
  }
}

