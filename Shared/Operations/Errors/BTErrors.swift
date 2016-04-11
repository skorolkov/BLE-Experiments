//
//  BTErrors.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

struct BTCentralManagerStateInvalidError: ErrorType {
    
    let expectedState: CBCentralManagerState
    let realState: CBCentralManagerState
    
    init(withExpectedState expectedState: CBCentralManagerState, realState: CBCentralManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
}

struct BTPeripheralManagerStateInvalidError: ErrorType {
    
    let expectedState: CBPeripheralManagerState
    let realState: CBPeripheralManagerState
    
    init(withExpectedState expectedState: CBPeripheralManagerState, realState: CBPeripheralManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
}

struct BTCentralManagerDisconnectPeripheralError: ErrorType {
    let originalError: NSError?
    
    init(originalError: NSError?) {
        self.originalError = originalError
    }
}

