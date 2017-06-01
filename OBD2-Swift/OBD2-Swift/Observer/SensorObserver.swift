//
//  Observer.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


class ObserverType : NSObject {}

class Observer<T : CommandType> : ObserverType {
  private var observers : [Int : (_ descriptor : T.Descriptor?)->()] = [:]
  
  public func observe(command : T, block : @escaping (_ descriptor : T.Descriptor?)->()){
    observers[command.hashValue] = block
  }
  
  func dispatch(command : T, response : Response){
    let described = T.Descriptor(describe: response)
    
    let callback = observers[response.hashValue]
    callback?(described)
  }
  
  func removeAll(){
    observers.removeAll()
  }
}

class ObserverQueue {
  static let shared = ObserverQueue()
  
  private init(){}
  private var observers = Set<ObserverType>() // = [:]
  
  open func register(observer : ObserverType){
    observers.insert(observer)
  }
  
  open func unregister(observer : ObserverType){
    observers.remove(observer)
  }
  
  func dispatch<T : CommandType>(command : T, response : Response){
    observers.forEach {
      if let obs = $0 as? Observer<T> {
        obs.dispatch(command: command, response: response)
      }
    }
  }
}

class XWW {
  func xwdwa(){
    
    
    let observer = Observer<CommandE.Mode01>()
    observer.observe(command: .pid(number: 1)) { (descriptor) in
      _ = descriptor?.descriptionStringForMeasurement()
    }
    
    ObserverQueue.shared.register(observer: observer)
    
    
  }
}
