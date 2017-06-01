//
//  Observer.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class SensorObserver {
  private var observers : [AnyHashable : Array<Observable>] = [:]
  
  func add(observer : Observable, for sensor: OBD2Sensor){
    observers[sensor]?.append(observer)
  }
  
  func remove(from sensor: OBD2Sensor){
    observers.removeValue(forKey: sensor)
  }
  
  func removeAll(){
    observers.removeAll()
  }
  
  func dispatch(value : Any, for sensor : OBD2Sensor){
    observers[sensor]?.forEach({
      $0.didChange(value: value, for: sensor)
    })
  }
}
