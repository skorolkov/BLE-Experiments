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
    
    // MARK: Private Properties
    
    private var valueToWrite: NSData
    private var charactericticToWrite: CBCharacteristic
    private var writeType: CBCharacteristicWriteType
    
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
        
        centralManager?.addHandler(self)
        peripheral?.addHandler(self)
        
        peripheral?.writeValue(valueToWrite,
            forCharacteristic: charactericticToWrite,
            type: writeType)
        
        if writeType == .WithoutResponse {
            removeHandlerAndFinish()
        }
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTPeripheralWriteValueOperation: BTCentralManagerHandlerProtocol {
    
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
        
        removeHandlerAndFinish()
    }
}
