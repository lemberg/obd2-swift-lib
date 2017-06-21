//
//  SensorDescriptor.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 27/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

//------------------------------------------------------------------------------
// Sensor Descriptor Structures

/* A structure to house a description of the type and range of a given sensor */

/*
 Some PIDs will return two measurements, thus we must take this into
 consideration as we build our decoding table.
 */

struct SensorDescriptor {
  init(  _ pid : Int8,
         _ description : String,
         _ shortDescription : String,
         _ metricUnit : String,
         _ minMetricValue : Int,
         _ maxMetricValue : Int,
         _ imperialUnit : String,
         _ minImperialValue : Int,
         _ maxImperialValue : Int,
         _ calcFunction : ((Data)->(Float))?,
         _ convertFunction : ((Float)->(Float))?) {
    
    self.pid = pid
    self.description = description
    self.shortDescription = shortDescription
    self.metricUnit = metricUnit
    self.minMetricValue = minMetricValue
    self.maxMetricValue = maxMetricValue
    self.imperialUnit = imperialUnit
    self.minImperialValue = minImperialValue
    self.maxImperialValue = maxImperialValue
    self.calcFunction = calcFunction
    self.convertFunction = convertFunction
  }
  
  var pid : Int8
  var description : String
  var shortDescription : String
  var metricUnit : String
  var minMetricValue : Int
  var maxMetricValue : Int
  var imperialUnit : String
  var minImperialValue : Int
  var maxImperialValue : Int
  /* A function pointer definition for calculation functions */
  var calcFunction : ((Data)->(Float))?
  /* A function pointer definition for conversion functions */
  var convertFunction : ((Float)->(Float))?
}
