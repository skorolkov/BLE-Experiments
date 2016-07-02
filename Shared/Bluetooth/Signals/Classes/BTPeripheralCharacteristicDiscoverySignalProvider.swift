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
    
    private let centralManager: BTCentralManagerAPIType
    private let peripheral: BTPeripheralAPIType
    private let servicePrototypes: [BTService]?
    private let characteristicPrototypes: [BTCharacteristic]?
    
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         servicePrototypes: [BTService],
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.servicePrototypes = servicePrototypes
        self.characteristicPrototypes = nil
        self.centralRolePerformer = centralRolePerformer
    }
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         characteristicPrototypes: [BTCharacteristic],
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.servicePrototypes = nil
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
                Log.bluetooth.verbose("BTPeripheralCharacteristicDiscoverySignalProvider: " +
                    "discovered services: \(discoverOperation.updatedPeripheral?.services)")
                
                if let discoveredPeripheral = discoverOperation.updatedPeripheral {
                    strongSelf.centralRolePerformer.updateManagedPeripheral(discoveredPeripheral)
                    let modelPeripheral = BTPeripheral.createWithDiscoveredPeripheral(discoveredPeripheral)
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
