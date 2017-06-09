//
//  OBD2Facade.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


protocol ScanDelegate {
    func didReceive()
}

open class OBD2 {
    
    public typealias CallBack = (Bool, Error?) -> ()
    
    private var host : String
    private var port : Int
    
    var scanner : Scanner
    
    public var stateChanged: StateChangeCallback? {
        didSet {
            scanner.stateChanged = stateChanged
        }
    }
    
    public convenience init(){
        self.init(host : "192.168.0.10", port : 35000)
    }
    
    public init(host : String, port : Int){
        self.host = host
        self.port = port
        
        self.scanner = Scanner(host: host, port: port)
    }
    
    var logger : Any?
    var cache : Any?
    
    public func connect(_ block : @escaping CallBack){
        scanner.startScan { (success, error) in
            block(success, error)
        }
    }
    
    public func disconnect() {
        scanner.disconnect()
    }
    
    public func stopScan() {
        scanner.cancelScan()
    }
    
    open func pauseScan() {
        scanner.pauseScan()
    }
    
    open func resumeScan() {
        scanner.resumeScan()
    }
    
    public func request<T: CommandType>(command: T, block: @escaping (_ descriptor: T.Descriptor?)->()){
        let dataRequest = command.dataRequest
        
        scanner.request(command: dataRequest, response: { (response) in
            let described = T.Descriptor(describe: response)
            block(described)
            
            self.dispatchToObserver(command: command, with: response)
        })
    }
    
    public func request<T: CommandType>(repeat command: T) {
        let dataRequest = command.dataRequest
        scanner.startRepeatCommand(command: dataRequest) { (response) in
            self.dispatchToObserver(command: command, with: response)
        }
    }
    
    public func stop<T: CommandType>(repeat command: T) {
        let dataRequest = command.dataRequest
        scanner.stopRepeatCommand(command: dataRequest)
    }
    
    public func isRepeating<T: CommandType>(repeat command: T) -> Bool {
        let dataRequest = command.dataRequest
        return scanner.isRepeating(command: dataRequest)
    }
    
    private func dispatchToObserver<T : CommandType>(command : T, with response : Response){
        ObserverQueue.shared.dispatch(command: command, response: response)
    }
}


