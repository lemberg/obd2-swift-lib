//
//  StreamWriter.swift
//  OBD2Swift
//
//  Created by Sergiy Loza on 30.05.17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

class StreamWriter {
    
    private(set) var stream:OutputStream
    private(set) var data:Data
    
    init(stream: OutputStream, data: Data) {
        self.stream = stream
        self.data = data
    }
    
    func write() throws {
        print("Write to OBD \(String(describing: String(data: data, encoding: .ascii)))")
        
        while data.count > 0 {
            let bytesWritten = write(data: data)
            
            if bytesWritten == -1 {
                print("Write Error")
                throw WriterError.writeError
            } else if bytesWritten > 0 && data.count > 0 {
                print("Wrote \(bytesWritten) bytes")
                data.removeSubrange(0..<bytesWritten)
            }
        }
    }
    
    private func write(data: Data) -> Int {
        var bytesRemaining = data.count
        var totalBytesWritten = 0
        
        while bytesRemaining > 0 {
            let bytesWritten = data.withUnsafeBytes {
                stream.write(
                    $0.advanced(by: totalBytesWritten),
                    maxLength: bytesRemaining
                )
            }
            if bytesWritten < 0 {
                print("Can not OutputStream.write()   \(stream.streamError?.localizedDescription ?? "")")
                return -1
            } else if bytesWritten == 0 {
                print("OutputStream.write() returned 0")
                return totalBytesWritten
            }
            
            bytesRemaining -= bytesWritten
            totalBytesWritten += bytesWritten
        }
        
        return totalBytesWritten
        
    }
}
