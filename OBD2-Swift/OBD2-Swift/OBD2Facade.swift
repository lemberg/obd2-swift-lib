//
//  OBD2Facade.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

open class OBD2 {
  private var host : String
  private var port : Int
  
  var scanner : Scanner
  var connector : Connector
  var observer : SensorObserver

  public convenience init(){
    self.init(host : "192.168.0.10", port : 35000)
  }
  
  public init(host : String, port : Int){
    self.host = host
    self.port = port
    
    self.connector = Connector()
    self.observer = SensorObserver()
    self.scanner = Scanner(host: host, port: port)
    
    connector.scanner = scanner
    scanner.connector = connector
    scanner.observer = observer
  }
  
  var logger : Any?
  var cache : Any?
  
  public func connect(_ block : Connector.CallBack){
    scanner.startScan()
  }
  
  public func disconnect(){
    //
  }
  
  public func startScan(){
    
  }
  
  public func stopScan(){
    
  }
  
  public func setSensors(){
    
  }
  
  public func requestTroubleCodes(){
    scanner.request(command: Command.init(from: "03"))
  }
}
