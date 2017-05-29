//
//  ViewController.swift
//  OBD2-Swift-lib-example
//
//  Created by Max Vitruk on 25/04/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import UIKit
import OBD2Swift

class ViewController: UIViewController {
  static var host = "192.168.0.10"
  static var port = 35000
  
  //var scanTool = ELM327(host: host , port: port)
  let obd = OBD2()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    

    obd.connect({ _, _ in })
  
    // Do any additional setup after loading the view, typically from a nib.
    
    //scanTool.sensorScanTargets = [0x0C, 0x0D]

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //scanTool.startScan()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    //scanTool.pauseScan()
  }

  @IBAction func request( _ sender : UIButton){
    obd.requestTroubleCodes()
  }
  
  @IBAction func requestVIN( _ sender : UIButton){
    obd.requestVIN()
  }
  
  @IBAction func requestSpeed( _ sender : UIButton){
    //obd.requestVIN()
    obd.request(command : "0100")
  }

}

