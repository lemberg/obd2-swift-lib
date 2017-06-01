//
//  Logger.swift
//  OBD2Swift
//
//  Created by Hellen Soloviy on 5/31/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation
import UIKit

//func print(_ string: String) {
//    Logger.shared.log(string)
////    NSLog(string)
//}

enum LoggerMessageType {
    
    case debug
    case error
    case info
    case verbose //default
    case warning
    
}


enum LoggerSourceType {
    
    case console
    case file //default
    
}

open class Logger {
    
    static var sourceType: LoggerSourceType = .console
    static let queue = OperationQueue()
    
    static let filePaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("//OBD2Logger.txt") ?? "/OBD2Logger.txt"
    
    public static func warning(_ message:String) {
        newLog(message, type: .warning)
    }
    
    public static func info(_ message:String) {
        newLog(message, type: .info)
    }
    
    public static func error(_ message:String) {
        newLog(message, type: .error)

    }
    
    public static func shareFile(on viewController: UIViewController) {
        
        let activityVC = UIActivityViewController(activityItems: fileToShare(), applicationActivities: nil)
        viewController.present(activityVC, animated: true, completion: nil)
        
    }
    
    public static func fileToShare() -> [Any] {
        
        let comment = "Logger file"
        let fileURL = URL(fileURLWithPath: filePaths)
        return [comment, fileURL] as [Any]
        
    }

    
    public static func cleanLoggerFile() {
        
        do {
            try  " ".write(toFile: filePaths, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            print("Failed writing to log file: \(filePaths), Error: " + error.localizedDescription)
        }
    }
    
    
    private static func newLog(_ message:String, type: LoggerMessageType = .verbose) {
        
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            
            let log = "[\(Date().description)] [\(type)] \(message)"

            var content = ""
            if FileManager.default.fileExists(atPath: filePaths) {
                content =  try! String(contentsOfFile: filePaths, encoding: String.Encoding.utf8)
            }
            
            do {
                try  "\(content)\n\(log)".write(toFile: filePaths, atomically: true, encoding: String.Encoding.utf8)
                
            } catch let error {
                print("Failed writing to log file: \(filePaths), Error: " + error.localizedDescription)
            }
            
        }

    }
    
    
}
