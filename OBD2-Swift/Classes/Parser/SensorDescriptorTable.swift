//
//  SensorDescriptorTable.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 27/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

//------------------------------------------------------------------------------
//MARK: -
//MARK: Global Sensor Table

let NULL = ""
let VOID : ((Data)->(Float))? = nil
let VOID_F : ((Float)->(Float))? = nil
let INT_MAX = Int.max


let SensorDescriptorTable : [SensorDescriptor] = [
    //MARK:- PID 0x00
    SensorDescriptor(0x00,
                     "Supported PIDs $00",  //  Description
                     "",                    //  Short Description
                     NULL,                  //  Units Metric
                     INT_MAX,               //  Min Metric
                     INT_MAX,               //  Max Metric
                     NULL,                  //  Units Imperial
                     INT_MAX,               //  Min Imperial
                     INT_MAX,               //  Max Imperial
                     VOID,                  //  Calc Function
                     VOID_F ),              //  Convert Function
    
    //MARK:- PID 0x01
    SensorDescriptor(0x01,
                     "Monitor status since DTCs cleared",
                     "Includes Malfunction Indicator Lamp (MIL) status and number of DTCs.",
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     VOID,
                     VOID_F),
    
    //MARK:- PID 0x02
    SensorDescriptor(0x02,
                     "Freeze Frame Status",
                     "",
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     VOID,
                     VOID_F ),
    
    
    //MARK:- PID 0x03
    /* PID $03 decodes to a string description, not a numeric value */
    SensorDescriptor(0x03,
                     "Fuel System Status",
                     "Fuel Status",
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     VOID,
                     VOID_F ),
    
    //MARK:- PID 0x03
    SensorDescriptor(0x03,
                     "Calculated Engine Load Value",
                     "Eng. Load",
                     "%",
                     0,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcPercentage,
                     VOID_F),
    
    //MARK:- PID 0x05
    SensorDescriptor(0x05,
                     "Engine Coolant Temperature",
                     "ECT",
                     "˚C",
                     -40,
                     215,
                     "˚F",
                     -40,
                     419,
                     calcTemp,
                     convertTemp),
    
    //MARK:- PID 0x06
    SensorDescriptor(0x06,
                     "Short term fuel trim: Bank 1",
                     "SHORTTF1",
                     "%",
                     -100,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcFuelTrimPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x07
    SensorDescriptor(0x07,
                     "Long term fuel trim: Bank 1",
                     "LONGTF1",
                     "%",
                     -100,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcFuelTrimPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x08
    SensorDescriptor(0x08,
                     "Short term fuel trim: Bank 2",
                     "SHORTTF2",
                     "%",
                     -100,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcFuelTrimPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x09
    SensorDescriptor(0x09,
                     "Long term fuel trim: Bank 2",
                     "LONGTF2",
                     "%",
                     -100,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcFuelTrimPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x0A
    SensorDescriptor(0x0A,
                     "Fuel Pressure",
                     "Fuel Pressure",
                     "kPa",
                     0,
                     765,
                     "inHg",
                     0,
                     222,
                     VOID,
                     convertPressure ),
    
    //MARK:- PID 0x0B
    SensorDescriptor(0x0B,
                     "Intake Manifold Pressure",
                     "IMP",
                     "kPa",
                     0, 255,
                     "inHg",
                     0,
                     74,
                     calcInt,
                     convertPressure ),
    
    //MARK:- PID 0x0C
    SensorDescriptor(0x0C,
                     "Engine RPM",
                     "RPM",
                     "RPM",
                     0,
                     16384,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcEngineRPM,
                     VOID_F ),
    
    //MARK:- PID 0x0D
    SensorDescriptor(0x0D,
                     "Vehicle Speed",
                     "Speed",
                     "km/h",
                     0,
                     255,
                     "MPH",
                     0,
                     159,
                     calcInt,
                     convertSpeed ),
    
    //MARK:- PID 0x0E
    SensorDescriptor(0x0E,
                     "Timing Advance",
                     "Time Adv.",
                     "i",
                     -64,
                     64,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcTimingAdvance,
                     VOID_F ),
    
    //MARK:- PID 0x0F
    SensorDescriptor(0x0F,
                     "Intake Air Temperature",
                     "IAT",
                     "C",
                     -40,
                     215,
                     "F",
                     -40,
                     419,
                     calcTemp,
                     convertTemp ),
    
    //MARK:- PID 0x10
    SensorDescriptor(0x10,
                     "Mass Air Flow",
                     "MAF",
                     "g/s",
                     0,
                     656,
                     "lbs/min",
                     0,
                     87,
                     calcMassAirFlow,
                     convertAir ),
    
    //MARK:- PID 0x11
    SensorDescriptor(0x11,
                     "Throttle Position",
                     "ATP",
                     "%",
                     0,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x12
    /* PID $12 decodes to a string description, not a numeric value */
    SensorDescriptor(0x12,
                     "Secondary Air Status",
                     "Sec Air",
                     NULL, INT_MAX, INT_MAX, NULL, INT_MAX, INT_MAX, VOID, VOID_F ),
    
    //MARK:- PID 0x13
    /* PID $13 decodes to a string description, not a numeric value	*/
    SensorDescriptor(0x13,
                     "Oxygen Sensors Present",
                     "O2 Sensors",
                     NULL, INT_MAX, INT_MAX, NULL, INT_MAX, INT_MAX, VOID, VOID_F ),
    
    //MARK:- PID 0x14
    SensorDescriptor(0x14,
                     "Oxygen Voltage: Bank 1, Sensor 1",
                     "OVB1S1",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F),
    
    //MARK:- PID 0x15
    SensorDescriptor(0x15,
                     "Oxygen Voltage: Bank 1, Sensor 2",
                     "OVB1S2",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F ),
    
    //MARK:- PID 0x16
    SensorDescriptor(0x16,
                     "Oxygen Voltage: Bank 1, Sensor 3",
                     "OVB1S3",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F ),
    
    //MARK:- PID 0x17
    SensorDescriptor(0x17,
                     "Oxygen Voltage: Bank 1, Sensor 4",
                     "OVB1S4",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F ),
    
    //MARK:- PID 0x18
    SensorDescriptor(0x18,
                     "Oxygen Voltage: Bank 2, Sensor 1",
                     "OVB1S1",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F ),
    
    
    //MARK:- PID 0x19
    SensorDescriptor(0x19,
                     "Oxygen Voltage: Bank 2, Sensor 2",
                     "OVB1S2",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F ),
    
    //MARK:- PID 0x1A
    SensorDescriptor(0x1A,
                     "Oxygen Voltage: Bank 2, Sensor 3",
                     "OVB1S3",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F ),
    
    //MARK:- PID 0x1B
    SensorDescriptor(0x1B,
                     "Oxygen Voltage: Bank 2, Sensor 4",
                     "OVB1S4",
                     "V",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcOxygenSensorVoltage,
                     VOID_F ),
    
    //MARK:- PID 0x1C
    /* PID $1C decodes to a string description, not a numeric value	*/
    SensorDescriptor(0x1C,
                     "OBD standards to which this vehicle conforms",
                     "OBD Standard",
                     NULL, INT_MAX, INT_MAX, NULL, INT_MAX, INT_MAX, VOID, VOID_F ),
    
    //MARK:- PID 0x1D
    /* PID $1D decodes to a string description, not a numeric value	*/
    SensorDescriptor(0x1D,
                     "Oxygen Sensors Present",
                     "O2 Sensors",
                     NULL, INT_MAX, INT_MAX, NULL, INT_MAX, INT_MAX, VOID, VOID_F ),
    
    //MARK:- PID 0x1E
    /* PID $1E decodes to a string description, not a numeric value	*/
    SensorDescriptor(0x1E,
                    "Auxiliary Input Status",
                    "Aux Input",
                    NULL, INT_MAX, INT_MAX, NULL, INT_MAX, INT_MAX, VOID, VOID_F ),
    
    //MARK:- PID 0x1F
    SensorDescriptor(0x1F,
                     "Run Time Since Engine Start",
                     "Run Time",
                     "sec",
                     0,
                     65535,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcTime,
                     VOID_F ),
    
    //MARK:- PID 0x20
    /* PID 0x20: List Supported PIDs 0x21-0x3F */
    /* No calculation or conversion */
    SensorDescriptor(0x20,
                     "List Supported PIDs", "Supported PIDs",
                     "",
                     0,
                     0,
                     NULL, INT_MAX, INT_MAX, VOID, VOID_F ),
    
    //MARK:- PID 0x21
    SensorDescriptor(0x21,
                     "Distance traveled with malfunction indicator lamp (MIL) on",
                     "MIL Traveled",
                     "Km",
                     0,
                     65535,
                     "miles",
                     0,
                     40717,
                     calcDistance,
                     convertDistance ),
    
    //MARK:- PID 0x22
    SensorDescriptor(0x22,
                     "Fuel Rail Pressure (Manifold Vacuum)",
                     "Fuel Rail V.",
                     "kPa",
                     0,
                     5178,
                     "inHg",
                     0,
                     1502,
                     calcPressure,
                     convertPressure),
    
    //MARK:- PID 0x23
    SensorDescriptor(0x23,
                     "Fuel Rail Pressure (Diesel)",
                     "Fuel Rail D.",
                     "kPa",
                     0,
                     655350,
                     "inHg",
                     0,
                     190052,
                     calcPressureDiesel,
                     convertPressure ),
    
    //MARK:- PID 0x24
    SensorDescriptor(0x24,
                     "Equivalence Ratio: O2S1",
                     "R O2S1",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x25
    SensorDescriptor(0x25,
                     "Equivalence Ratio: O2S2",
                     "R O2S2",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x26
    SensorDescriptor(0x26,
                     "Equivalence Ratio: O2S3",
                     "R O2S3",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x27
    SensorDescriptor(0x27,
                     "Equivalence Ratio: O2S4", "R O2S4",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x28
    SensorDescriptor(0x28,
                     "Equivalence Ratio: O2S5", "R O2S5",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x29
    SensorDescriptor(0x29,
                     "Equivalence Ratio: O2S6", "R O2S6",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x2A
    SensorDescriptor(0x2A,
                     "Equivalence Ratio: O2S7", "R O2S7",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x2B
    SensorDescriptor(0x2B,
                     "Equivalence Ratio: O2S8", "R O2S8",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x2C
    SensorDescriptor(0x2C,
                     "Commanded EGR",
                     "EGR",
                     "%",
                     0,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x2D
    SensorDescriptor(0x2D,
                     "EGR Error", "EGR Error", "%",
                     -100,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcEGRError,
                     VOID_F ),
    
    //MARK:- PID 0x2E
    SensorDescriptor(0x2E,
                     "Commanded Evaporative Purge",
                     "Cmd Purge",
                     "%",
                     0,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x2F
    SensorDescriptor(0x2F,
                     "Fuel Level Input",
                     "Fuel Level",
                     "%",
                     0,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x30
    SensorDescriptor(0x30,
                     "Number of Warm-Ups Since Codes Cleared",
                     "# Warm-Ups",
                     "",
                     0,
                     255,
                     NULL, INT_MAX, INT_MAX,
                     calcInt,
                     VOID_F ),
    
    //MARK:- PID 0x31
    SensorDescriptor(0x31,
                     "Distance Traveled Since Codes Cleared", "Cleared Traveled",
                     "Km",
                     0,
                     65535,
                     "miles",
                     0,
                     40717,
                     calcDistance,
                     convertDistance),
    
    //MARK:- PID 0x32
    SensorDescriptor(0x32,
                     "Evaporative System Vapor Pressure",
                     "Vapor Pressure",
                     "Pa",
                     -8192,
                     8192,
                     "inHg",
                     -3,
                     3,
                     calcVaporPressure,
                     convertPressure2 ),
    
    //MARK:- PID 0x33
    SensorDescriptor(0x33,
                     "Barometric Pressure",
                     "Bar. Pressure",
                     "kPa",
                     0,
                     255,
                     "inHg",
                     0,
                     76,
                     calcInt,
                     convertPressure ),
    
    //MARK:- PID 0x34
    SensorDescriptor(0x34,
                     "Equivalence Ratio: O2S1",
                     "R O2S1",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX,
                     calcEquivalenceRatio,
                     VOID_F ),
    
    //MARK:- PID 0x35
    SensorDescriptor(0x35,
                     "Equivalence Ratio: O2S2",
                     "R O2S2",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX,
                     calcEquivalenceRatio,
                     VOID_F ),
    
    //MARK:- PID 0x36
    SensorDescriptor(0x36,
                     "Equivalence Ratio: O2S3",
                     "R O2S3",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX,
                     calcEquivalenceRatio,
                     VOID_F ),
    
    //MARK:- PID 0x37
    SensorDescriptor(0x37,
                     "Equivalence Ratio: O2S4",
                     "R O2S4",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX,
                     calcEquivalenceRatio,
                     VOID_F ),
    
    //MARK:- PID 0x38
    SensorDescriptor(0x38,
                     "Equivalence Ratio: O2S5",
                     "R O2S5",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x39
    SensorDescriptor(0x39,
                     "Equivalence Ratio: O2S6",
                     "R O2S6",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x3A
    SensorDescriptor(0x3A,
                     "Equivalence Ratio: O2S7",
                     "R O2S7",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    //MARK:- PID 0x3B
    SensorDescriptor(0x3B,
                     "Equivalence Ratio: O2S8",
                     "R O2S8",
                     "", 0, 2,
                     NULL, INT_MAX, INT_MAX, calcEquivalenceRatio, VOID_F ),
    
    
    //MARK:- PID 0x3C
    SensorDescriptor(0x3C,
                     "Catalyst Temperature: Bank 1, Sensor 1",
                     "CT B1S1",
                     "C",
                     -40,
                     6514,
                     "F",
                     -40,
                     11694,
                     calcCatalystTemp,
                     convertTemp ),
    
    //MARK:- PID 0x3D
    SensorDescriptor(0x3D,
                     "Catalyst Temperature: Bank 2, Sensor 1",
                     "CT B2S1",
                     "C",
                     -40,
                     6514,
                     "F",
                     -40,
                     11694,
                     calcCatalystTemp,
                     convertTemp ),
    
    //MARK:- PID 0x3E
    SensorDescriptor(0x3E,
                     "Catalyst Temperature: Bank 1, Sensor 2",
                     "CT B1S2",
                     "C",-40,
                     6514,
                     "F",
                     -40,
                     11694,
                     calcCatalystTemp,
                     convertTemp ),
    
    //MARK:- PID 0x3F
    SensorDescriptor(0x3F,
                     "Catalyst Temperature: Bank 2, Sensor 2",
                     "CT B2S2",
                     "C",
                     -40,
                     6514,
                     "F",
                     -40,
                     11694,
                     calcCatalystTemp,
                     convertTemp ),
    
    
    //MARK:- PID 0x40
    /* PID 0x40: List Supported PIDs 0x41-0x5F */
    /* No calculation or conversion */
    SensorDescriptor(0x40,
                     NULL, NULL, NULL, INT_MAX, INT_MAX, NULL, INT_MAX, INT_MAX, VOID, VOID_F ),
    
    //MARK:- PID 0x41
    //TODO: - Decode PID $41 correctly
    SensorDescriptor(0x41,
                     "Monitor status this drive cycle",
                     "Monitor status",
                     NULL, INT_MAX, INT_MAX, NULL, INT_MAX, INT_MAX, VOID, VOID_F),
    
    //MARK:- PID 0x42
    SensorDescriptor(0x42,
                     "Control Module Voltage",
                     "Ctrl Voltage",
                     "V",
                     0,
                     66,
                     NULL, INT_MAX, INT_MAX,
                     calcControlModuleVoltage,
                     VOID_F ),
    
    //MARK:- PID 0x43
    SensorDescriptor(0x43,
                     "Absolute Load Value",
                     "Abs Load Val",
                     "%",
                     0,
                     25700,
                     NULL, INT_MAX, INT_MAX,
                     calcAbsoluteLoadValue,
                     VOID_F ),
    
    //MARK:- PID 0x44
    SensorDescriptor(0x44,
                     "Command Equivalence Ratio",
                     "Cmd Equiv Ratio",
                     "",
                     0,
                     2,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcEquivalenceRatio,
                     VOID_F),
    
    //MARK:- PID 0x45
    SensorDescriptor(0x45,
                     "Relative Throttle Position",
                     "Rel Throttle Pos",
                     "%",
                     0,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcPercentage, VOID_F ),
    
    //MARK:- PID 0x46
    SensorDescriptor(0x46,
                     "Ambient Air Temperature",
                     "Amb Air Temp",
                     "C",
                     -40,
                     215,
                     "F",
                     -104,
                     355,
                     calcTemp,
                     convertTemp ),
    
    //MARK:- PID 0x47
    SensorDescriptor(0x47,
                     "Absolute Throttle Position B",
                     "Abs Throt Pos B",
                     "%",
                     0,
                     100,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x48
    SensorDescriptor(0x48,
                     "Absolute Throttle Position C",
                     "Abs Throt Pos C",
                     "%",
                     0,100,
                     NULL, INT_MAX, INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x49
    SensorDescriptor(0x49,
                     "Accelerator Pedal Position D",
                     "Abs Throt Pos D",
                     "%",
                     0, 100,
                     NULL, INT_MAX, INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x4A
    SensorDescriptor(0x4A,
                     "Accelerator Pedal Position E",
                     "Abs Throt Pos E",
                     "%",
                     0, 100,
                     NULL, INT_MAX, INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x4B
    SensorDescriptor(0x4B,
                     "Accelerator Pedal Position F",
                     "Abs Throt Pos F",
                     "%",
                     0, 100,
                     NULL, INT_MAX, INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x4C
    SensorDescriptor(0x4C,
                     "Commanded Throttle Actuator",
                     "Cmd Throttle Act", "%",
                     0, 100,
                     NULL, INT_MAX, INT_MAX,
                     calcPercentage,
                     VOID_F ),
    
    //MARK:- PID 0x4D
    SensorDescriptor(0x4D,
                     "Time Run With MIL On",
                     "MIL Time On",
                     "min",
                     0,
                     65535,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcTime,
                     VOID_F ),
    
    //MARK:- PID 0x4E
    SensorDescriptor(0x4E,
                     "Time Since Trouble Codes Cleared",
                     "DTC Cleared Time",
                     "min",
                     0,
                     65535,
                     NULL,
                     INT_MAX,
                     INT_MAX,
                     calcTime,
                     VOID_F )
]

