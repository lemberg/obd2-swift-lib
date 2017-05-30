//
//  OpenOBDConnectionOperation.swift
//  OBD2Swift
//
//  Created by Sergiy Loza on 30.05.17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class OpenOBDConnectionOperation: StreamHandleOperation {
    
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["inputOpen" as NSObject, "outOpen" as NSObject]
    }
    
    private var inputOpen = false {
        didSet {
            if inputOpen {
                print("Input stream opened")
                input.remove(from: .current, forMode: .defaultRunLoopMode)
            }
        }
    }
    
    private var outOpen = false {
        didSet {
            if outOpen {
                print("Output stream opened")
                output.remove(from: .current, forMode: .defaultRunLoopMode)
            }
        }
    }
    
    override var isFinished: Bool {
        return inputOpen && outOpen
    }
    
    override func main() {
        super.main()
    }
    
    override func execute() {
        input.open()
        output.open()
    }
    
    override func inputStremEvent(event: Stream.Event) {
        if event == .openCompleted {
            inputOpen = true
        }
    }
    
    override func outputStremEvent(event: Stream.Event) {
        if event == .openCompleted {
            outOpen = true
        }
    }
}
