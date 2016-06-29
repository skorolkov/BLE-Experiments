//
//  BTPeripheralScanSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import Operations

class BTPeripheralScanSignalProvider {
    
    // MARK: Private Properties

    private var centralManager: BTCentralManagerAPIType
    private var serviceUUIDs: [CBUUID]? = nil
    private var options: [String : AnyObject]? = nil
    private var allowDuplicatePeripheralIds: Bool = false
    private var timeout: NSTimeInterval = 10
    private var validatePeripheralPredicate: BTCentralManagerScanningOperation.BTScanningValidPeripheralPredicate? = nil
    private var stopScanningCondition: BTCentralManagerScanningOperation.BTScanningStopBlock
    
    private var centralRolePerformer: BTCentralRolePerforming
    
    private var scanOperation: BTCentralManagerScanningOperation? = nil
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         serviceUUIDs: [CBUUID]? = nil,
         options: [String : AnyObject]? = nil,
         allowDuplicatePeripheralIds: Bool = false,
         timeout: NSTimeInterval = 10,
         validatePeripheralPredicate: BTCentralManagerScanningOperation.BTScanningValidPeripheralPredicate? = nil,
         stopScanningCondition: BTCentralManagerScanningOperation.BTScanningStopBlock,
         centralRolePerformer: BTCentralRolePerforming) {
        
        self.centralManager = centralManager
        self.serviceUUIDs = serviceUUIDs
        self.options = options
        self.allowDuplicatePeripheralIds = allowDuplicatePeripheralIds
        self.timeout = timeout
        self.validatePeripheralPredicate = validatePeripheralPredicate
        self.stopScanningCondition = stopScanningCondition
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Internal Methods
    
    func scan() -> SignalProducer<[BTPeripheral], BTError> {
        
        return SignalProducer { observer, disposable in
            let startScanningOperation = BTCentralManagerScanningOperation(
                centralManager: self.centralManager,
                serviceUUIDs: self.serviceUUIDs,
                options: self.options,
                allowDuplicatePeripheralIds: self.allowDuplicatePeripheralIds,
                timeout: self.timeout,
                intermediateScanResultBlock: {
                    [weak self] (discoveredPeripherals: [BTPeripheralAPIType]) in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    for discoveredPeripheral in discoveredPeripherals {
                        strongSelf.centralRolePerformer.updateManagedPeripheral(discoveredPeripheral)
                    }
                    
                    let modelPeripherals = discoveredPeripherals.map {
                        BTPeripheralScanSignalProvider.modelPeripheralWithScannedPeripheral($0)
                    }
                    
                    for modelPeripheral in modelPeripherals {
                        strongSelf.centralRolePerformer.updateModelPeripheral(modelPeripheral)
                    }
                    
                    observer.sendNext(modelPeripherals)
                },
                stopScanningCondition: self.stopScanningCondition)
            
            startScanningOperation.addObserver(DidFinishObserver { [weak self] (operation, errors) in
                
                guard let strongSelf = self else {
                    return
                }
                
                if operation.finished && errors.count > 0 {
                    
                    let timeoutErrorIndex = errors.indexOf({
                        if let timeoutError = $0 as? OperationError {
                            if case .OperationTimedOut(_) = timeoutError {
                                return true
                            }
                        }
                        return false
                    })
                    
                    if timeoutErrorIndex == nil {
                        let error = BTOperationError(code: .OperationFailed(errors: errors))
                        Log.bluetooth.error("BTPeripheralScanSignalProvider: scanning, error: \(error)")
                        observer.sendFailed(error)
                        return
                    }
                }
                
                guard let scanningOperation = operation as? BTCentralManagerScanningOperation else {
                    let error = BTOperationError(code: .OperationTypeMismatch)
                    Log.bluetooth.error("BTPeripheralScanSignalProvider: scanning, error: \(error)")
                    observer.sendFailed(error)
                    return
                }
                
                Log.bluetooth.info("BTPeripheralScanSignalProvider: scan completed, " +
                    "discovered peripherals: \(scanningOperation.discoveredPeripherals)")
                
                for discoveredPeripheral in scanningOperation.discoveredPeripherals {
                    strongSelf.centralRolePerformer.updateManagedPeripheral(discoveredPeripheral)
                }
                
                let modelPeripherals = scanningOperation.discoveredPeripherals.map {
                    BTPeripheralScanSignalProvider.modelPeripheralWithScannedPeripheral($0)
                }
                
                for modelPeripheral in modelPeripherals {
                    strongSelf.centralRolePerformer.updateModelPeripheral(modelPeripheral)
                }
                
                observer.sendNext(modelPeripherals)
                observer.sendCompleted()
                })
            
            self.scanOperation = startScanningOperation
            
            self.centralRolePerformer.operationQueue.addOperation(startScanningOperation)
        }
    }
    
    func stopScan() {
        //TODO: save reference to disposable to interrupt SignalProducer = ???
        scanOperation?.cancel()
        scanOperation = nil
    }
}

// MARK: Supporting Methods

private extension BTPeripheralScanSignalProvider {
    static func modelPeripheralWithScannedPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheral {
        return BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                            name: peripheral.name,
                            state: .Scanned)
    }
}
