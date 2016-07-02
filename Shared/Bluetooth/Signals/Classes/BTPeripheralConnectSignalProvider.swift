//
//  BTPeripheralConnectSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Operations

class BTPeripheralConnectSignalProvider {
    
    // MARK: Privare Properties
    
    private let centralManager: BTCentralManagerAPIType
    private let peripheral: BTPeripheralAPIType
    private let options: [String : AnyObject]?
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         options: [String : AnyObject]? = nil,
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.peripheral = peripheral
        self.options = options
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Internal Methods
    
    func connect() -> SignalProducer<[BTPeripheral], BTError> {
        
        return SignalProducer { observer, disposable in
            let connectOperation = BTCentralManagerConnectingOperation(
                centralManager: self.centralManager,
                peripheral: self.peripheral,
                options: self.options)
            
            connectOperation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if operation.finished && errors.count > 0 {
                    let error = BTOperationError(code: .OperationFailed(errors: errors))
                    Log.bluetooth.error("BTPeripheralConnectSignalProvider: failed connect to peripheral " +
                        "with id=\(strongSelf.peripheral.identifier), error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                guard let connectOperation = operation as? BTCentralManagerConnectingOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    Log.bluetooth.error("BTPeripheralConnectSignalProvider: failed connect to peripheral " +
                        "with id=\(strongSelf.peripheral.identifier), error: \(error)")
                    observer.sendFailed(error)
                    return
                }

                Log.bluetooth.info("BTPeripheralConnectSignalProvider: connect completed, " +
                                           "connected peripheral: \(connectOperation.updatedPeripheral)")
                
                if let connectedPeripheral = connectOperation.updatedPeripheral {
                    strongSelf.centralRolePerformer.updateManagedPeripheral(connectedPeripheral)
                    let modelPeripheral = BTPeripheral.createWithConnectedPeripheral(connectedPeripheral)
                    strongSelf.centralRolePerformer.updateModelPeripheral(modelPeripheral)

                    observer.sendNext([modelPeripheral])
                }
                else {
                    observer.sendNext([])
                }

                observer.sendCompleted()
                })
            
            self.centralRolePerformer.operationQueue.addOperation(connectOperation)
        }
    }
}
