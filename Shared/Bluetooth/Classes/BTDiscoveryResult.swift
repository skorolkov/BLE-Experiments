//
//  BTDiscoveryResult.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/11/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation

enum BTDiscoveryResult<Attribute, Error: ErrorType> {
    case Success(value: Attribute)
    case Failure(error: Error)
    case NotFound
}