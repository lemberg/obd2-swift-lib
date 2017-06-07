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
    
    @IBOutlet weak var dtcButton: UIButton!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var vinButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        //scanTool.sensorScanTargets = [0x0C, 0x0D]
        updateUI(connected: false)
        let observer = Observer<Command.Mode01>()
        
        observer.observe(command: .pid(number: 12)) { (descriptor) in
            let respStr = descriptor?.shortDescription
            print("Observer : \(respStr)")
        }
        
        ObserverQueue.shared.register(observer: observer)
    }
    
    func updateUI(connected: Bool) {
        dtcButton.isEnabled = connected
        speedButton.isEnabled = connected
        vinButton.isEnabled = connected
        connectButton.isHidden = connected
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //scanTool.startScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //scanTool.pauseScan()
    }
    
    @IBAction func connect( _ sender : UIButton){
        //obd.requestTroubleCodes()
        statusLabel.text = "Connecting"
        connectButton.isHidden = true
        indicator.startAnimating()
        
        obd.connect { [weak self] (success, error) in
            OperationQueue.main.addOperation({
                self?.indicator.stopAnimating()
                if let error = error {
                    print("OBD connection failed with \(error)")
                    self?.statusLabel.text = "Connection failed with error \(error)"
                    self?.connectButton.isEnabled = true
                } else {
                    print("OBD connection success")
                    self?.statusLabel.text = "Connected"
                    self?.updateUI(connected: true)
                }
            })
        }
    }
    
    
    
    @IBAction func request( _ sender : UIButton){
        //obd.requestTroubleCodes()
        obd.request(command: Command.Mode03.troubleCode) { (descriptor) in
            let respStr = descriptor?.getTroubleCodes()
            print(respStr ?? "No value")
        }
    }
    
    @IBAction func requestVIN( _ sender : UIButton){
        //obd.requestVIN()
        obd.request(command: Command.Mode09.vin) { (descriptor) in
            let respStr = descriptor?.VIN()
            print(respStr ?? "No value")
        }
    }
    
    @IBAction func requestSpeed( _ sender : UIButton){
        //    obd.request(command : "0100")
        //    
        obd.request(command: Command.Mode01.pid(number: 12)) { (descriptor) in
            let respStr = descriptor?.stringRepresentation(metric: true)
            print(respStr ?? "No value")
        }
    }
    
}

