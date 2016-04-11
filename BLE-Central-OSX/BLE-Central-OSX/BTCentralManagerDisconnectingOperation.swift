//
//  BTCentralManagerDisconnectingOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/11/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

struct BTCentralManagerFailToDisconnectPeripheral: ErrorType {
    let originalError: NSError?
    
    init(originalError: NSError?) {
        self.originalError = originalError
    }
}

class BTCentralManagerDisconnectingOperation: BTCentralManagerOperation {
    
    // MARK: Private Properties
    
    private var peripheral: BTPeripheralAPIType
    
    // MARK: Initializers
    
    init(withCentralManager centralManager: BTCentralManagerAPIType,
                            peripheral: BTPeripheralAPIType) {
        self.peripheral = peripheral
        
        super.init(withCentralManager: centralManager)
        
        addCondition(BTCentralManagerPoweredOnCondition(withCentralManager: centralManager))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        
        centralManager?.cancelPeripheralConnectionWithObject(peripheral)
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTCentralManagerDisconnectingOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                                error: NSError?) {
        let btError: ErrorType? = (error != nil) ?
            BTCentralManagerFailToDisconnectPeripheral(originalError: error) : nil
        removeHandlerAndFinish(btError)
    }
}
