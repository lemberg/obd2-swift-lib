//
//  Observer.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation


protocol ObserverType {}

class Observer<T : CommandType> : ObserverType {
  private var observers : [Mode : (_ descriptor : T.Descriptor?)->()] = [:]
  
  public func observe(command : T, block : @escaping (_ descriptor : T.Descriptor?)->()){
    observers[command.mode] = block
  }
  
  func dispatch(command : T, response : Response){
    let described = T.Descriptor(describe: response)
    
    let callback = observers[response.mode]
    callback?(described)
  }
  
  func removeAll(){
    observers.removeAll()
  }
}

class ObserverQueue {
  private var observers : [Mode : ObserverType] = [:]
  func add(observer : ObserverType, for mode : Mode){
    observers[mode] = observer
  }
  
  func dispatch<T : CommandType>(command : T, response : Response){
    let observer = observers[response.mode]
    
    if let obs = observer as? Observer<T> {
      obs.dispatch(command: command, response: response)
    }
  }
}

class XWW {
  func xwdwa(){
    
    
    let observer = Observer<CommandE.Mode01>()
    observer.observe(command: .pid(number: 1)) { (descriptor) in
      _ = descriptor?.descriptionStringForMeasurement()
    }
    
    
  }
}
