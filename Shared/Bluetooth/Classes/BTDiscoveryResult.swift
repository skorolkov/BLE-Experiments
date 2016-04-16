//
//  BTDiscoveryResult.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/11/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

//struct BTDiscoveryResult<Attribute, Error: ErrorType> {
//    
//    let discoveredAttribute: Attribute?
//    let error: Error?
//
//    init(discoveredAttribute: Attribute? = nil, error: Error? = nil) {
//        self.discoveredAttribute = discoveredAttribute
//        self.error = error
//    }
//}

enum BTDiscoveryResult<Attribute, Error: ErrorType> {
    case Success(value: Attribute)
    case Failure(error: Error)
    case NotFound
}