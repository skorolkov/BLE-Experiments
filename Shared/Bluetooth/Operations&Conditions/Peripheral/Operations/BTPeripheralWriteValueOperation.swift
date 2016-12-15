//
//  BTPeripheralWriteValueOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

class BTPeripheralWriteValueOperation: BTPeripheralOperation {
    
    // MARK: Internal Properties
    
    private(set) var updatedCharacteristic: CBCharacteristic? = nil
    
    // MARK: Private Properties
    
    private let valueToWrite: NSData
    private let charactericticToWrite: CBCharacteristic
    private let writeType: CBCharacteristicWriteType
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         valueToWrite: NSData,
         charactericticToWrite: CBCharacteristic,
         writeType: CBCharacteristicWriteType = .WithResponse) {
        
        self.valueToWrite = valueToWrite
        self.charactericticToWrite = charactericticToWrite
        self.writeType = writeType
        
        super.init(centralManager: centralManager,
                   peripheral: peripheral)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
        addCondition(BTPeripheralConnectedCondition(peripheral: peripheral))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        if writeType == .WithoutResponse {
            peripheral?.writeValue(valueToWrite,
                                   forCharacteristic: charactericticToWrite,
                                   type: .WithoutResponse)
            finish()
        } else {
            centralManager?.addHandler(self)
            peripheral?.addHandler(self)
            
            peripheral?.writeValue(valueToWrite,
                                   forCharacteristic: charactericticToWrite,
                                   type: writeType)
        }
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTPeripheralWriteValueOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        
        if central.managerState != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(expectedState: .PoweredOn,
                                                          realState: central.managerState)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(
        central: BTCentralManagerAPIType,
        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                error: NSError?) {
        
        let btError: ErrorType? = (error != nil) ?
                BTCentralManagerDidDisconnectPeripheralError(originalError: error) : nil
        removeHandlerAndFinish(btError)
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTPeripheralWriteValueOperation: BTPeripheralHandlerProtocol {
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didWriteValueForCharacteristic characteristic: CBCharacteristic,
                                       error: NSError?) {
        
        if let originalError = error {
            let btError = BTPeripheralWriteValueForCharacteristicError(
                characteristicUUID: (characteristic.UUID.copy() as! CBUUID),
                originalError: originalError)
            removeHandlerAndFinish(btError)
            return
        }
        
        updatedCharacteristic = characteristic
        
        removeHandlerAndFinish()
    }
}
