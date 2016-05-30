//
//  BTPeripheralReadValueOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

class BTPeripheralReadValueOperation: BTPeripheralOperation {
    
    // MARK: Internal Properties
    
    private(set) var value: NSData? = nil
    
    // MARK: Private Properties
    
    private var charactericticToRead: CBCharacteristic
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         charactericticToRead: CBCharacteristic) {
        
        self.charactericticToRead = charactericticToRead
        
        super.init(centralManager: centralManager,
                   peripheral: peripheral)
        
        // FIXME: add CBPeripheral's state condition
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
    }

    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        peripheral?.addHandler(self)
        
        peripheral?.readValueForCharacteristic(charactericticToRead)
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTPeripheralReadValueOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(
        central: BTCentralManagerAPIType,
        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                error: NSError?) {
        
        let btError: ErrorType? = (error != nil) ?
            BTCentralManagerFailToConnectPeripheralError(originalError: error) : nil
        removeHandlerAndFinish(btError)
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTPeripheralReadValueOperation: BTPeripheralHandlerProtocol {
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
                                        error: NSError?) {
        
        if let originalError = error {
            let btError = BTPeripheralUpdateValueForCharacteristicError(
                characteristicUUID: (characteristic.UUID.copy() as! CBUUID),
                originalError: originalError)
            removeHandlerAndFinish(btError)
            return
        }
        
        value = (characteristic.value?.copy() as! NSData)
        removeHandlerAndFinish()
    }
}
