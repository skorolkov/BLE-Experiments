//
//  BTCentralManagerDisconnectingOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/11/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

class BTCentralManagerDisconnectingOperation: BTCentralManagerOperation {
    
    // MARK: Private Properties
    
    private var peripheral: BTPeripheralAPIType
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType) {
        
        self.peripheral = peripheral
        
        super.init(centralManager: centralManager)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
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
            BTCentralManagerFailToConnectPeripheralError(originalError: error) : nil
        removeHandlerAndFinish(btError)
    }
}
