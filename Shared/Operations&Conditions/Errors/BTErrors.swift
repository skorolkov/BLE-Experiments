//
//  BTErrors.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTError: ErrorType {}

final class BTCentralManagerStateInvalidError: BTError {
    
    let expectedState: CBCentralManagerState
    let realState: CBCentralManagerState
    
    init(withExpectedState expectedState: CBCentralManagerState, realState: CBCentralManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
}

final class BTPeripheralManagerStateInvalidError: BTError {
    
    let expectedState: CBPeripheralManagerState
    let realState: CBPeripheralManagerState
    
    init(withExpectedState expectedState: CBPeripheralManagerState, realState: CBPeripheralManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
}

final class BTCentralManagerFailToConnectPeripheralError: BTError {
    let originalError: NSError?
    
    init(originalError: NSError?) {
        self.originalError = originalError
    }
}

final class BTPeriphalServiceDiscoveryError: BTError {
    let originalError: NSError?
    
    init(originalError: NSError?) {
        self.originalError = originalError
    }
}

