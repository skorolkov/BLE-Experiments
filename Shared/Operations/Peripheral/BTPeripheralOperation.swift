//
//  BTPeripheralOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/11/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import Operations

class BTPeripheralOperation: Operation {
    
    // MARK: Private Properties
    
    private(set) weak var centralManager: BTCentralManagerAPIType?
    private(set) weak var peripheral: BTPeripheralAPIType?
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType) {
        self.centralManager = centralManager
        self.peripheral = peripheral
    }
    
    // MARK: Internal Methods
    
    func removeHandlerAndFinish(error: ErrorType? = nil) {
        if let centralHandler = self as? BTCentralManagerHandlerProtocol {
            centralManager?.removeHandler(centralHandler)
        }
        if let peripheralHandler = self as? BTPeripheralHandlerProtocol {
            peripheral?.removeHandler(peripheralHandler)
        }
        finish(error)
    }
}