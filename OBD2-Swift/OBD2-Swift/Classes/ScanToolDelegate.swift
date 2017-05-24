//
//  ScanToolDelegate.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

protocol ScanToolDelegate : class {
  func didUpdateSensor(sensor : ECUSensor)
  func scanDidStart(scanTool : ScanTool)
  func scanDidPause(scanTool : ScanTool)
  func scanDidCancel(scanTool : ScanTool)
  
  func scanToolWillSleep(scanTool : ScanTool)
  func scanToolDidConnect(scanTool : ScanTool)
  func scanToolDidDisconnect(scanTool : ScanTool)
  func scanToolDidInitialize(scanTool : ScanTool)
  func scanToolDidFailToInitialize(scanTool : ScanTool)
  
  func didSendCommand(scanTool : ScanTool, command : ScanToolCommand) //ScanToolCommand
  func didReceiveResponse(scanTool : ScanTool, responses : Array<Any>)
  func didReceiveVoltage(scanTool : ScanTool, voltage : String)
  func didTimeoutOnCommand(scanTool : ScanTool, command : ScanToolCommand) //ScanToolCommand
  func didReceiveError(scanTool : ScanTool, error : Error)
}
