//
//  DescriptorStringRepresentation.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 31/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

public class StringDescriptor : DescriptorProtocol {
  public var response : Response
  
  public required init(describe response : Response) {
    self.response = response
    self.mode = response.mode
  }
  
  public var mode : Mode
  
  public func getResponse() -> String? {
    guard let data = response.data else {return nil}
    return String.init(data: data, encoding: String.Encoding.ascii)
  }
}
