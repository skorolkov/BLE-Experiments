//
//  BTPeripheralDisconnectSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Operations

public final class BTPeripheralDisconnectSignalProvider {
    
    // MARK: Privare Properties
    
    private let centralManager: BTCentralManagerAPIType
    private let peripheral: BTPeripheralAPIType
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Public Methods
    
    public func disconnect() -> SignalProducer<BTPeripheral?, BTError> {
        
        return SignalProducer { observer, disposable in
            let disconnectOperation = BTCentralManagerDisconnectingOperation(
                centralManager: self.centralManager,
                peripheral: self.peripheral)
            
            disconnectOperation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard let disconnectOperation = operation as? BTCentralManagerDisconnectingOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    BTLog.defaultLog.error("BTPeripheralDisconnectSignalProvider: failed to disconnect from peripheral with id=\(strongSelf.peripheral.identifier.UUIDString), error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                var disconnectError: NSError? = nil
                
                if let disconnectErrorIndex = errors.indexOf({ ($0 is BTCentralManagerDidDisconnectPeripheralError) }) {
                    disconnectError = (errors[disconnectErrorIndex] as? BTCentralManagerDidDisconnectPeripheralError)?.originalError
                }
                
                if errors.count > 0 && disconnectError == nil  {
                    let error = BTOperationError(code: .OperationFailed(errors: errors))
                    BTLog.defaultLog.error("BTPeripheralDisconnectSignalProvider: failed to disconnect from peripheral with id=\(strongSelf.peripheral.identifier.UUIDString), error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                BTLog.defaultLog.info("BTPeripheralDisconnectSignalProvider: disconnect completed, disconnected peripheral: \(disconnectOperation.updatedPeripheral)")
                
                if let disconnectedPeripheral = disconnectOperation.updatedPeripheral {
                    strongSelf.centralRolePerformer.updateManagedPeripheral(disconnectedPeripheral)
                    let modelPeripheral = BTPeripheral.createWithDisconnectedPeripheral(
                        disconnectedPeripheral,
                        error: disconnectError)
                    strongSelf.centralRolePerformer.updateModelPeripheral(modelPeripheral)
                    
                    observer.sendNext(modelPeripheral)
                }
                else {
                    observer.sendNext(nil)
                }
                
                observer.sendCompleted()
                })
            
            self.centralRolePerformer.operationQueue.addOperation(disconnectOperation)
        }
    }
}
