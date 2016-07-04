//
//  BTWriteCharacteristicSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import Operations

class BTWriteCharacteristicSignalProvider {
    
    // MARK: Privare Properties
    
    private let centralManager: BTCentralManagerAPIType
    private let peripheral: BTPeripheralAPIType
    private let valueToWrite: NSData
    private let characterictic: CBCharacteristic
    private let writeType: CBCharacteristicWriteType
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         valueToWrite: NSData,
         charactericticToWrite: CBCharacteristic,
         writeType: CBCharacteristicWriteType = .WithResponse,
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.valueToWrite = valueToWrite
        self.characterictic = charactericticToWrite
        self.writeType = writeType
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Internal Methods
    
    func write() -> SignalProducer<BTPeripheral?, BTError> {
        return SignalProducer { observer, disposable in
            
            let operation = BTPeripheralWriteValueOperation(
                centralManager: self.centralManager,
                peripheral: self.peripheral,
                valueToWrite: self.valueToWrite,
                charactericticToWrite: self.characterictic,
                writeType: self.writeType)
            
            operation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if operation.finished && errors.count > 0 {
                    let error = BTOperationError(code: .OperationFailed(errors: errors))
                    Log.bluetooth.error("BTWriteCharacteristicSignalProvider: " +
                        "failed to write value for peripheral " +
                        "with id=\(strongSelf.peripheral.identifier.UUIDString), " +
                        "for characteristic id=\(strongSelf.characterictic.UUID) error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                guard let writeOperation = operation as? BTPeripheralWriteValueOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    Log.bluetooth.error("BTWriteCharacteristicSignalProvider: " +
                        "failed to write value for peripheral " +
                        "with id=\(strongSelf.peripheral.identifier.UUIDString), " +
                        "for characteristic id=\(strongSelf.characterictic.UUID) error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                let characterictic = writeOperation.updatedCharacteristic ?? strongSelf.characterictic

                
                Log.bluetooth.info("BTWriteCharacteristicSignalProvider: write value=\(strongSelf.valueToWrite)"
                    + " for characteristic with id=\(characterictic.UUID)")
                
                let previousPeripheralModel = strongSelf.centralRolePerformer.modelPeripheralWithIdentifier(
                    strongSelf.peripheral.identifier.UUIDString)
                
                let newPeripheralModel = BTPeripheral.createWithPeripheral(
                    strongSelf.peripheral,
                    state: previousPeripheralModel?.state ?? .Unknown,
                    characteristic: characterictic)
                
                observer.sendNext(newPeripheralModel)
                observer.sendCompleted()
                
                })
            
            self.centralRolePerformer.operationQueue.addOperation(operation)
        }
        
    }
}