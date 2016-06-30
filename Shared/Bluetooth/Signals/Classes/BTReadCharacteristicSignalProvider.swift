//
//  BTPeripheralReadCharacteristicSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import Operations

class BTReadCharacteristicSignalProvider {
    
    // MARK: Privare Properties
    
    private let centralManager: BTCentralManagerAPIType
    private let peripheral: BTPeripheralAPIType
    private var characterictic: CBCharacteristic
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         characterictic: CBCharacteristic,
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.characterictic = characterictic
        self.centralRolePerformer = centralRolePerformer
    }

    // MARK: Internal Methods
    
    func read() -> SignalProducer<[BTPeripheral], BTError> {
        return SignalProducer { observer, disposable in
            
            let operation = BTPeripheralReadValueOperation(
                centralManager: self.centralManager,
                peripheral: self.peripheral,
                charactericticToRead: self.characterictic)
            
            operation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if operation.finished && errors.count > 0 {
                    let error = BTOperationError(code: .OperationFailed(errors: errors))
                    Log.bluetooth.error("BTReadCharacteristicSignalProvider: " +
                        "failed to read value for peripheral " +
                        "with id=\(strongSelf.peripheral.identifier), " +
                        "for characteristic id=\(strongSelf.characterictic.UUID) error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                guard let readOperation = operation as? BTPeripheralReadValueOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    Log.bluetooth.error("BTReadCharacteristicSignalProvider: " +
                        "failed to read value for peripheral " +
                        "with id=\(strongSelf.peripheral.identifier), " +
                        "for characteristic id=\(strongSelf.characterictic.UUID) error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                Log.bluetooth.info("BTReadCharacteristicSignalProvider: read value=\(readOperation.value)"
                    + " for characteristic with id=\(strongSelf.characterictic.UUID)")
                    
                if let updatedCharacteristic = readOperation.updatedCharacteristic {
                    
                    let previousPeripheralModel = strongSelf.centralRolePerformer.modelPeripheralWithIdentifier(
                        strongSelf.peripheral.identifier.UUIDString)
                    
                    let newPeripheralModel = BTPeripheral.createWithPeripheral(
                        strongSelf.peripheral,
                        state: previousPeripheralModel?.state ?? .Unknown,
                        characteristic: updatedCharacteristic)
                    
                    observer.sendNext([newPeripheralModel])
                }
                else {
                    observer.sendNext([])
                }
                
                observer.sendCompleted()
                })
            
            self.centralRolePerformer.operationQueue.addOperation(operation)
        }
        
    }
}
