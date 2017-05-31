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

class Logger {
    
    static let shared = Logger()
    
//    let fileName = "/Logger_test_file.txt"
    let filePaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/Logger_test_file.txt") ?? "/Users/hellensoloviy/Downloads/OBD2Logger.txt"
//    let filePaths =  NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .localDomainMask, true).first?.appending(Logger.shared.fileName) ?? "/Users/hellensoloviy/Downloads/OBD2Logger.txt"
    
    func redirectLogToDocuments() {
//        freopen(Logger.shared.filePaths.cString(using: String.Encoding.ascii)!, "a+", stderr)
//        freopen(Logger.shared.filePaths.cString(using: String.Encoding.ascii)!, "a+", stdin)
//        freopen(Logger.shared.filePaths.cString(using: String.Encoding.ascii)!, "a+", stdout)
        removeFile()
    }
    
    func log(_ message:String) {
        
        var dump = ""

        if FileManager.default.fileExists(atPath: filePaths) {
            dump =  try! String(contentsOfFile: filePaths, encoding: String.Encoding.utf8)
        }
        

        do {
            try  "\(dump)\n \(Date().description) -- \(message)".write(toFile: filePaths, atomically: true, encoding: String.Encoding.utf8)
            
        } catch let error {
            print("Failed writing to log file: \(filePaths), Error: " + error.localizedDescription)
        }
        
    }
    
    func removeFile() {
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: filePaths)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
}
