//
//  GloablCalculator.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 27/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

//------------------------------------------------------------------------------
//MARK: - Global Calculation Functions


/*!
 method calcInt
 */
func calcInt(data : Data) -> Float {
  return Float(data[0])
}

/*!
 method calcTime
 */

func calcTime(data : Data) -> Float {
  let dataA = Int16(data[0])
  let dataB = Int16(data[1])
  let result = (dataA * 256) + dataB
  return Float(result)
}

/*!
 method calcTimingAdvance
 */

func calcTimingAdvance(data : Data) -> Float {
  let dataA	= Float(data[0])
  return (dataA / 2) - 64
}

/*!
 method calcDistance
 */

func calcDistance(data : Data) -> Float {
  let dataA = Int16(data[0])
  let dataB = Int16(data[1])
  let result = (dataA * 256) + dataB
  return Float(result)
}

/*!
 method calcPercentage
 */

func calcPercentage(data : Data) -> Float {
  return (Float(data[0]) * 100) / 255
}

/*!
 method calcAbsoluteLoadValue
 */

func calcAbsoluteLoadValue(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) * 100) / 255
}

/*!
 method calcTemp
 */

func calcTemp(data : Data) -> Float {
  let temp = Float(data[0])
  return temp - 40
}

/*!
 method calcCatalystTemp
 */

func calcCatalystTemp(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) / 10) - 40
}

/*!
 method calcFuelTrimPercentage
 */

func calcFuelTrimPercentage(data : Data) -> Float {
  let value = Float(data[0])
  return (0.7812 * (value - 128))
}

/*!
 method calcFuelTrimPercentage2
 */
func calcFuelTrimPercentage2(data : Data) -> Float {
  let value = Float(data[1])
  return (0.7812 * (value - 128))
}


/*!
 method calcEngineRPM
 */

func calcEngineRPM(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) / 4)
}

/*!
 method calcOxygenSensorVoltage
 */

func calcOxygenSensorVoltage(data : Data) -> Float {
  let dataA = Float(data[0])
  return (dataA * 0.005)
}

/*!
 method calcControlModuleVoltage
 */

func calcControlModuleVoltage(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) / 1000)
}

/*!
 method calcMassAirFlow
 */

func calcMassAirFlow(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) / 100)
}

/*!
 method calcPressure
 */

func calcPressure(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) * 0.079)
}

/*!
 method calcPressureDiesel
 */

func calcPressureDiesel(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) * 10)
}

/*!
 method calcVaporPressure
 */

func calcVaporPressure(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return ((((dataA * 256) + dataB) / 4) - 8192)
}

/*!
 method calcEquivalenceRatio
 */

func calcEquivalenceRatio(data : Data) -> Float {
  let dataA					= Float(data[0])
  let dataB					= Float(data[1])
  
  return (((dataA * 256) + dataB) * 0.0000305)
}

/*!
 method calcEquivalenceVoltage
 */

func calcEquivalenceVoltage(data : Data) -> Float {
  let dataC					= Float(data[2])
  let dataD					= Float(data[3])
  
  return (((dataC * 256) + dataD) * 0.000122)
}

/*!
 method calcEquivalenceCurrent
 */

func calcEquivalenceCurrent(data : Data) -> Float {
  let dataC					= Float(data[2])
  let dataD					= Float(data[3])
  
  return (((dataC * 256) + dataD) * 0.00390625) - 128
}

/*!
 method calcEGRError
 */

func calcEGRError(data : Data) -> Float {
  let dataA					= Float(data[0])
  
  return ((dataA * 0.78125) - 100)
}

/*!
 method calcInstantMPG
 */
func calcInstantMPG(vss : Double, maf : Double) -> Double {
  var _vss = vss
  var _maf = maf
  
  if(_vss > 255) {
    _vss = 255;
  }
	 
  if(_vss < 0) {
    _vss = 0
  }
  
	 
  if(_maf <= 0) {
    _maf = 0.1
  }
	 
  var mpg	: Double = 0.0
  let mph	: Double	= (_vss * 0.621371) // convert KPH to MPH
  
  mpg			= ((14.7 * 6.17 * 454 * mph) / (3600 * _maf))
  
  return mpg
}


func calcMILActive(data : [UInt8]) -> Bool {
  guard data.count < 4 else {
    return false
  }
  
  let dataA = data[0]
  
  return (dataA & 0x80) != 0
}

//------------------------------------------------------------------------------
//MARK: -
//MARK: Global Conversion Functions

/*
 @method convertTemp
 @param value: the temperature in degress Celsius (C)
 @return: the temperature in degrees Fahrenheit (F)
 */

func convertTemp(value : Float) -> Float {
  return ((value * 9) / 5) + 32;
}

/*
 @method convertPressure
 @param value: the pressure in kiloPascals (kPa)
 @return: the pressure in inches of Mercury (inHg)
 */

func convertPressure(value : Float) -> Float {
  return (value / 3.38600);
}

/*
 @method convertPressure2
 @param value: the pressure in Pascals (Pa)
 @return: the pressure in inches of Mercury (inHg)
 */

func convertPressure2(value : Float) -> Float {
  return (value / 3386)
}

/*
 @method convertSpeed
 @param value: the speed in kilometers per hour (km/h)
 @return: the speed in miles per hour (mph)
 */

func convertSpeed(value : Float) -> Float {
  return (value * 62) / 100.0
}

/*
 @method convertAir
 @param value: the air flow in grams per second (g/s)
 @return: the air flow in pounds per minute (lb/min)
 */

func convertAir(value : Float) -> Float {
  return (value * 132) / 1000.0
}

/*
 @method convertDistance
 @param value: the distance in Km
 @return: the distance in Miles
 */

func convertDistance(value : Float) -> Float {
  return (value * 0.6213)
}

