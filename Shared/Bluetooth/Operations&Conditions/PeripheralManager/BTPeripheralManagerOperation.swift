//
//  BTPeripheralManagerOperation.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

class BTPeripheralManagerOperation: BTOperation {
    
    // MARK: Private Properties
    
    private(set) weak var peripheralManager: BTPeripheralManagerAPIType?
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        self.peripheralManager = peripheralManager
    }
    
    // MARK: Internal Methods
    
    func removeHandlerAndFinish(error: ErrorType? = nil) {
        if let handler = self as? BTPeripheralManagerHandlerProtocol {
            peripheralManager?.removeHandler(handler)
        }
        finish(error)
    }
}