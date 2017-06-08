//
//  StreamError.swift
//  OBD2Swift
//
//  Created by Sergiy Loza on 08.06.17.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

enum WriterError: Error {
    case writeError
}

enum StreamReaderError: Error {
    case readError
    case noBytesReaded
    case ELMError
}
