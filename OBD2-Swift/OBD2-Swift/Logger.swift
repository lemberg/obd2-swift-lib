//
//  Logger.swift
//  OBD2Swift
//
//  Created by Hellen Soloviy on 5/31/17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

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

class Logger {
    
    static var isColored = false
    static var sourceType: LoggerSourceType = .console
    static let queue = OperationQueue()
    
    static let filePaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("//OBD2Logger.txt") ?? "/OBD2Logger.txt"
    
    
    static func redirectLogToDocuments() {
        //TODO: ~hellen
        
        do {
            try  " ".write(toFile: filePaths, atomically: true, encoding: String.Encoding.utf8)
        } catch let error {
            print("Failed writing to log file: \(filePaths), Error: " + error.localizedDescription)
        }
        
    }
    
    static func warning(_ message:String) {
        newLog(message, type: .warning)
    }
    
    static func info(_ message:String) {
        newLog(message, type: .info)
    }
    
    static func error(_ message:String) {
        newLog(message, type: .error)

    }
    
    
    static func newLog(_ message:String, type: LoggerMessageType = .verbose) {
        
        queue.maxConcurrentOperationCount = 1
        queue.addOperation {
            
            let log = "[\(Date().description)] [\(type)] \(message)"
            print("\(log)")

            var content = ""
            if FileManager.default.fileExists(atPath: filePaths) {
                content =  try! String(contentsOfFile: filePaths, encoding: String.Encoding.utf8)
            }
            
            
//            print("hell - pre-saving - \(log)")
            do {
                
//                print("hell - saving - \(log)")
                try  "\(content)\n - \(log)".write(toFile: filePaths, atomically: true, encoding: String.Encoding.utf8)
                
            } catch let error {
                print("Failed writing to log file: \(filePaths), Error: " + error.localizedDescription)
            }
            
        }

    }
    
    static func log(_ message:String, type: LoggerMessageType = .verbose) {
        
//        guard sourceType == .file else {
        
        let log = "[\(Date().description)] [\(type)] \(message)"
        print("hell - printing - \(log)")
//            return
//        }
        
        
        var content = ""
        if FileManager.default.fileExists(atPath: filePaths) {
            content =  try! String(contentsOfFile: filePaths, encoding: String.Encoding.utf8)
        }
        
        do {
            
            print("hell - saving - \(log)")
            try  "\(content)\n - \(log)".write(toFile: filePaths, atomically: true, encoding: String.Encoding.utf8)
            
        } catch let error {
            print("Failed writing to log file: \(filePaths), Error: " + error.localizedDescription)
        }
    
        // Create a FileHandle instance
        //
//        let file: FileHandle? = FileHandle(forWritingAtPath: filePaths)
//        if file != nil {
//            // Set the data we want to write
//            let data = "23423423423 \( message)".data(using: String.Encoding.utf8)
//            
//            // Write it to the file
//            file?.write(data!)
//            
//            // Close the file
//            file?.closeFile()
//        }
//        else {
//            print("Ooops! Something went wrong!")
//        }

        
        
    }
    
    func shareFile() {
        
//        let fileManager = FileManager.default
        //TODO: sharing
        
    }
    
    static func removeFile() {
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: filePaths)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        
        }
    }
    
}
