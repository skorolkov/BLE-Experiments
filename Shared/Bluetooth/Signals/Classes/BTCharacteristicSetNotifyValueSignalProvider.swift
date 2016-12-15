//
//  BTCharacteristicSetNotifyValueSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import Operations

public final class BTCharacteristicSetNotifyValueSignalProvider {
    
    // MARK: Privare Properties
    
    private let centralManager: BTCentralManagerAPIType
    private let peripheral: BTPeripheralAPIType
    private let characterictic: CBCharacteristic
    private let notificationsEnabled: Bool
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         characterictic: CBCharacteristic,
         notificationsEnabled: Bool,
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.characterictic = characterictic
        self.notificationsEnabled = notificationsEnabled
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Public Methods
    
    public func setNotifyValue() -> SignalProducer<BTPeripheral?, BTError> {
        return SignalProducer { observer, disposable in
            let operation = BTPeripheralSetNotifyValueOperation(
                centralManager: self.centralManager,
                peripheral: self.peripheral,
                characterictic: self.characterictic,
                notificationEnabled: self.notificationsEnabled)
            
            operation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if operation.finished && errors.count > 0 {
                    let error = BTOperationError(code: .OperationFailed(errors: errors))
                    BTLog.defaultLog.error("BTCharacteristicSetNotifyValueSignalProvider: failed to set notify value for peripheral with id=\(strongSelf.peripheral.identifier.UUIDString), for characteristic id: \(strongSelf.characterictic.UUID) error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                guard let setNotifyOperation = operation as? BTPeripheralSetNotifyValueOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    BTLog.defaultLog.error("BTCharacteristicSetNotifyValueSignalProvider: failed to set notify value for peripheral with id=\(strongSelf.peripheral.identifier.UUIDString), for characteristic id: \(strongSelf.characterictic.UUID) error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
            
                BTLog.defaultLog.info("BTCharacteristicSetNotifyValueSignalProvider: update notify state for characteristic: \(setNotifyOperation.updatedCharacteristic)")
                
                if let updatedCharacteristic = setNotifyOperation.updatedCharacteristic {
                    
                    let previousPeripheralModel = strongSelf.centralRolePerformer.modelPeripheralWithIdentifier(
                        strongSelf.peripheral.identifier.UUIDString)
                    
                    let newPeripheralModel = BTPeripheral.createWithPeripheral(
                        strongSelf.peripheral,
                        state: previousPeripheralModel?.state ?? .Unknown,
                        characteristic: updatedCharacteristic)
                    
                    observer.sendNext(newPeripheralModel)
                }
                else {
                    observer.sendNext(nil)
                }
                
                observer.sendCompleted()
                })
            
            self.centralRolePerformer.operationQueue.addOperation(operation)
        }
        
    }
}
