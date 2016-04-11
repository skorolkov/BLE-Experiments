//
//  BTCentralManagerConnectingOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/10/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

struct BTCentralManagerFailToConnectPeripheral: ErrorType {
    let originalError: NSError?
    
    init(originalError: NSError?) {
        self.originalError = originalError
    }
}

class BTCentralManagerConnectingOperation: BTCentralManagerOperation {
    
    // MARK: Internal Properties
    
    private(set) var updatedPeripheral: BTPeripheralAPIType? = nil
    
    // MARK: Private Properties
    
    private var peripheral: BTPeripheralAPIType
    private var options: [String : AnyObject]? = nil
    
    // MARK: Initializers
    
    init(withCentralManager centralManager: BTCentralManagerAPIType,
                            peripheral: BTPeripheralAPIType,
                            options: [String : AnyObject]? = nil) {
        self.peripheral = peripheral
        
        super.init(withCentralManager: centralManager)
        
        addCondition(BTCentralManagerPoweredOnCondition(withCentralManager: centralManager))
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
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didConnectPeripheral peripheral: BTPeripheralAPIType) {
        
        updatedPeripheral = peripheral
        
        removeHandlerAndFinish()
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didFailToConnectPeripheral peripheral: BTPeripheralAPIType,
                                                   error: NSError?) {
        let btError = BTCentralManagerFailToConnectPeripheral(originalError: error)
        removeHandlerAndFinish(btError)
    }
}
