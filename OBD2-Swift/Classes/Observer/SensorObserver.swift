//
//  Observer.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


public class ObserverType : NSObject {}

// To bring Observer alive you must register it in ObserverQueue
// unregister func deactivates observer

public class Observer<T : CommandType> : ObserverType {
    private typealias DescriptorCallBack = (_ descriptor : T.Descriptor?)->()
    private typealias DescriptorArray = [(DescriptorCallBack)?]
    
    private var observers : [Int : DescriptorArray] = [:]
    
    public func observe(command : T, block : @escaping (_ descriptor : T.Descriptor?)->()){
        let key = command.hashValue
        let array = observers[key] ?? []
        let flatAray = array.compactMap({$0})
        observers[key] = flatAray
        observers[key]?.append(block)
    }
    
    func dispatch(command : T, response : Response){
        let described = T.Descriptor(describe: response)
        
        guard let callbackArray = observers[response.hashValue] else {return}
        
        for callback in callbackArray {
            callback?(described)
        }
    }
    
    func removeAll(){
        observers.removeAll()
    }
}

public class ObserverQueue {
    
    public static let shared = ObserverQueue()
    
    private let observingQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "com.obd2.observers"
        return queue
    }()
    
    private init(){}
    
    private var observers = Set<ObserverType>()
    
    open func register(observer : ObserverType){
        observers.insert(observer)
    }
    
    open func unregister(observer : ObserverType){
        observers.remove(observer)
    }
    
    func dispatch<T : CommandType>(command : T, response : Response) {
        observingQueue.addOperation {
            self.observers.forEach {
                if let obs = $0 as? Observer<T> {
                    obs.dispatch(command: command, response: response)
                }
            }
        }
    }
}
