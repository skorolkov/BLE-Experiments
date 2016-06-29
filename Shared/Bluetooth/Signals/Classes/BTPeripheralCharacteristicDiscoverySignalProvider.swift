//
//  BTPeripheralCharacteristicDiscoverySignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Operations

class BTPeripheralCharacteristicDiscoverySignalProvider {
    
    // MARK: Private Properties
    
    private var centralManager: BTCentralManagerAPIType
    private var peripheral: BTPeripheralAPIType
    private var servicePrototypes: [BTService]? = nil
    private var characteristicPrototypes: [BTCharacteristic]? = nil
    
    private var centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         servicePrototypes: [BTService],
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.servicePrototypes = servicePrototypes
        self.centralRolePerformer = centralRolePerformer
    }
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         characteristicPrototypes: [BTCharacteristic],
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.characteristicPrototypes = characteristicPrototypes
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Internal Methods
    
    func discover() -> SignalProducer<[BTPeripheral], BTError> {
        
        return SignalProducer { observer, disposable in
            
            var discoverOperation: BTPeripheralCharacteristicDiscoveryOperation
            
            if let servicePrototypes = self.servicePrototypes {
                discoverOperation = BTPeripheralCharacteristicDiscoveryOperation(
                    centralManager: self.centralManager,
                    peripheral: self.peripheral,
                    servicePrototypes: servicePrototypes)
            }
            else {
                discoverOperation = BTPeripheralCharacteristicDiscoveryOperation(
                    centralManager: self.centralManager,
                    peripheral: self.peripheral,
                    characteristicPrototypes: self.characteristicPrototypes ?? [])
            }
            
            discoverOperation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if operation.finished && errors.count > 0 {
                    let error = BTOperationError(code: .OperationFailed(errors: errors))
                    Log.bluetooth.error("BTPeripheralCharacteristicDiscoverySignalProvider: " +
                        "failed to discover characteristic for peripheral " +
                        "with id=\(strongSelf.peripheral.identifier), error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                guard let discoverOperation = operation as? BTPeripheralCharacteristicDiscoveryOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    Log.bluetooth.error("BTPeripheralCharacteristicDiscoverySignalProvider: " +
                        "failed to discover characteristic for peripheral " +
                            "with id=\(strongSelf.peripheral.identifier), error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                Log.bluetooth.info("BTPeripheralCharacteristicDiscoverySignalProvider: " +
                    "discover characteristic completed for peripheral with id=\(strongSelf.peripheral.identifier)")
                
                if let discoveredPeripheral = discoverOperation.updatedPeripheral {
                    strongSelf.centralRolePerformer.updateManagedPeripheral(discoveredPeripheral)
                    let modelPeripheral =
                        BTPeripheralCharacteristicDiscoverySignalProvider.modelPeripheralWithDiscoveredPeripheral(discoveredPeripheral)
                    strongSelf.centralRolePerformer.updateModelPeripheral(modelPeripheral)
                    
                    observer.sendNext([modelPeripheral])
                }
                else {
                    observer.sendNext([])
                }
                
                observer.sendCompleted()
                })
            
            self.centralRolePerformer.operationQueue.addOperation(discoverOperation)
        }
    }
}

// MARK: Supporting Methods

private extension BTPeripheralCharacteristicDiscoverySignalProvider {
    static func modelPeripheralWithDiscoveredPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheral {
        return BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                            name: peripheral.name,
                            state: .CharacteristicDiscovered)
    }
}
