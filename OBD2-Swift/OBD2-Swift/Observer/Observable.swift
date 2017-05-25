//
//  ObservableTypes.swift
//  OBD2Swift
//
//  Created by Max Vitruk on 24/05/2017.
//  Copyright © 2017 Lemberg. All rights reserved.
//

import Foundation

protocol Observable {
  func didChange(value : Any, for sensor : OBD2Sensor)
}
