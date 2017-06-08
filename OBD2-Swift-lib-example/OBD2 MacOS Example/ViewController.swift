//
//  ViewController.swift
//  OBD2 MacOS Example
//
//  Created by Max Vitruk on 08/06/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Cocoa
import OBD2SwiftMacOS

class ViewController: NSViewController {
  static var host = "192.168.0.10"
  static var port = 35000
  
  //var scanTool = ELM327(host: host , port: port)
  let obd = OBD2()
  
  @IBOutlet weak var dtcButton: NSButton!
  @IBOutlet weak var speedButton: NSButton!
  @IBOutlet weak var vinButton: NSButton!
  @IBOutlet weak var connectButton: NSButton!
  @IBOutlet weak var indicator: NSProgressIndicator!
  
  @IBOutlet weak var statusLabel: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    
    //scanTool.sensorScanTargets = [0x0C, 0x0D]
    updateUI(connected: false)
    let observer = Observer<Command.Mode01>()
    
    observer.observe(command: .pid(number: 12)) { (descriptor) in
      let respStr = descriptor?.shortDescription
      print("Observer : \(respStr ?? "")")
    }
    
    ObserverQueue.shared.register(observer: observer)
  }
  
  func updateUI(connected: Bool) {
    dtcButton.isEnabled = connected
    speedButton.isEnabled = connected
    vinButton.isEnabled = connected
    connectButton.isHidden = connected
  }
  
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  @IBAction func connect( _ sender : NSButton){
    //obd.requestTroubleCodes()
    statusLabel.stringValue = "Connecting"
    connectButton.isHidden = true
    indicator.style = .spinningStyle
    indicator.startAnimation(nil)
    
    obd.connect { [weak self] (success, error) in
      OperationQueue.main.addOperation({
        self?.indicator.stopAnimation(nil)
        if let error = error {
          print("OBD connection failed with \(error)")
          self?.statusLabel.stringValue = "Connection failed with error \(error)"
          self?.connectButton.isEnabled = true
        } else {
          print("OBD connection success")
          self?.statusLabel.stringValue = "Connected"
          self?.updateUI(connected: true)
        }
      })
    }
  }
  
  
  
  @IBAction func request( _ sender : NSButton){
    //obd.requestTroubleCodes()
    obd.request(command: Command.Mode03.troubleCode) { (descriptor) in
      let respStr = descriptor?.getTroubleCodes()
      print(descriptor?.response.strigDescriptor ?? "")
      print(respStr ?? "No value")
    }
  }
  
  @IBAction func requestVIN( _ sender : NSButton){
    //obd.requestVIN()
    obd.request(command: Command.Mode09.vin) { (descriptor) in
      let respStr = descriptor?.VIN()
      print(descriptor?.response.strigDescriptor ?? "")
      print(respStr ?? "No value")
    }
  }
  
  @IBAction func requestSpeed( _ sender : NSButton){
    //    obd.request(command : "0100")
    obd.request(command: Command.Mode01.pid(number: 12)) { (descriptor) in
      let respStr = descriptor?.stringRepresentation(metric: true)
      print(descriptor?.response.strigDescriptor ?? "")
      print(respStr ?? "No value")
    }
  }
}

