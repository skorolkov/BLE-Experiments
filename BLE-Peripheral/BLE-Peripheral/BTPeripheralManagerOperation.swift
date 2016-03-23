//
//  BTPeripheralManagerOperation.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

class BTPeripheralManagerOperation: Operation {
    
    // MARK: Private Properties
    
    private(set) weak var peripheralManager: BTPeripheralManagerProxy?
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerProxy) {
        self.peripheralManager = peripheralManager
    }

}