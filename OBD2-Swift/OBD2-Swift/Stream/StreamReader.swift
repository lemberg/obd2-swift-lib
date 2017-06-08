//
//  StreamReader.swift
//  OBD2Swift
//
//  Created by Sergiy Loza on 31.05.17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

typealias BufferType = UInt8

extension Array where Element == BufferType {
    
    func elmReadComplete() -> Bool {
        return last == Parser.string.kResponseFinishedCode
    }
}

extension String {
    
    var elmOK: Bool {
        return contains("OK")
    }
    
    var elmError: Bool	{
        return contains("?")
    }
    
    var elmNoData: Bool	{
        return contains("NO DATA")
    }
    
    var elmSearching: Bool {
        return contains("SEARCHING...")
    }
}

class StreamReader {
    
    private let bufferSize = 512
    
    private(set) var readBuffer = [BufferType]()
    private(set) var readBufferLenght = 0
    private(set) var stream:InputStream
    private(set) var response: String?
    
    init(stream: InputStream) {
        self.stream = stream
    }
    
    func read() throws -> Bool {
        
        var buffer = [UInt8].init(repeating: 0, count: bufferSize)
        let readLength = stream.read(&buffer, maxLength: bufferSize)
        print("Read \(readLength) bytes")
        
        guard readLength > 0 else {
            throw StreamReaderError.noBytesReaded
        }
        
        buffer.removeSubrange(readLength..<bufferSize)
        
        readBuffer += buffer
        readBufferLenght += readLength
        
        if readBuffer.elmReadComplete() {
            print("Read complete")
            if (readBufferLenght - 3) > 0 && (readBufferLenght - 3) < readBuffer.count {
                readBuffer[(readBufferLenght - 3)] = 0x00
                readBufferLenght	-= 3
            }
            
            let asciistr : [Int8] = readBuffer.map( { Int8(bitPattern: $0) } )
            let respString = String(cString: asciistr, encoding: String.Encoding.ascii) ?? ""
            
            print(respString)
            
            if respString.elmError {
                throw StreamReaderError.ELMError
            } else {
                response = respString
            }
            
            return true
        }
        return false
    }
}
































