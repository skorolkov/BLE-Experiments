//
//  BTCentralManagerConnectingOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/10/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

class BTCentralManagerConnectingOperation: BTCentralManagerOperation {
    
    // MARK: Internal Properties
    
    private(set) var updatedPeripheral: BTPeripheralAPIType? = nil
    
    // MARK: Private Properties
    
    private let peripheral: BTPeripheralAPIType
    private let options: [String : AnyObject]?
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         options: [String : AnyObject]? = nil) {
        self.peripheral = peripheral
        self.options = options
        
        super.init(centralManager: centralManager)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        
        centralManager?.connectPeripheralWithObject(peripheral, options: options)
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTCentralManagerConnectingOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        if central.managerState != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.managerState)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didConnectPeripheral peripheral: BTPeripheralAPIType) {
        guard peripheral.identifier == self.peripheral.identifier else {
            return
        }
        
        updatedPeripheral = peripheral
        
        removeHandlerAndFinish()
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didFailToConnectPeripheral peripheral: BTPeripheralAPIType,
                                                   error: NSError?) {
        let btError = BTCentralManagerFailToConnectPeripheralError(originalError: error)
        removeHandlerAndFinish(btError)
    }
}
