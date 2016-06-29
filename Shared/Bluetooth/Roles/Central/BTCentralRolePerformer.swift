//
//  BTCentralRolePerformer.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import Operations
import CocoaLumberjack
import ReactiveCocoa

class BTCentralRolePerformer: NSObject, BTCentralRolePerforming {
    
    // MARK: Singleton

    static let sharedInstance = BTCentralRolePerformer()

    // MARK: Signals
    
    typealias BTPeripheralNotifier = protocol<BTPeripheralUpdating, NSObjectProtocol>
    
    private(set) var peripheralDataProvider: BTPeripheralDataProvider = BTPeripheralDataProvider()
    
    private var peripheralNotifier: BTPeripheralNotifier {
        return peripheralDataProvider
    }
    
    private var managedPeripherals: [BTPeripheralAPIType] = []
    private var modelPeripherals: [BTPeripheral] = [] {
        didSet {
            peripheralNotifier.peripheralsToUpdate.value = modelPeripherals
        }
    }
    
    // MARK: Operations
    
    private(set) var operationQueue: OperationQueue
    private var scanOperation: BTCentralManagerScanningOperation? = nil

    // MARK: Central Manager
    
    private var centralManager: BTCentralManagerAPIWithHadlerProtocol
    
    // MARK: Initializers
    
    override init() {
        
        // WARNING: the same dispatch_queue used for OperationQueue and for CBCentralManager
        let queueName = "com.bluetooth.\(self.dynamicType)"
        let queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT)
        
        operationQueue = OperationQueue()
        operationQueue.name = queueName
        operationQueue.underlyingQueue = queue
        
        let bluetoothCentralManager = CBCentralManager(
            delegate: nil,
            queue: queue,
            options: [CBCentralManagerOptionShowPowerAlertKey : true])
        
        centralManager = BTCentralManagerProxy(centralManager: bluetoothCentralManager)
        
        super.init()
        
        centralManager.addHandler(self)
        
        centralManager.addHandler(BTCentralManagerLoggingHandler())
    }
    
    // MARK: Internal Methods
    
    func updateManagedPeripheral(peripheral: BTPeripheralAPIType) {
        if let index = managedPeripherals.indexOf( { $0.identifier.isEqual(peripheral.identifier) } ) {
            managedPeripherals[index] = peripheral
        }
        else {
            managedPeripherals.append(peripheral)
        }
    }
    
    func updateModelPeripheral(peripheral: BTPeripheral) {
        if let index = modelPeripherals.indexOf( { $0.identifierString == peripheral.identifierString } ) {
            modelPeripherals[index] = peripheral
        }
        else {
            modelPeripherals.append(peripheral)
        }
    }
    
    // MARK: Get Peripheral
    
    func peripheralWithIdentifier(identifierString: String) -> BTPeripheralAPIType? {
        guard let index = managedPeripherals.indexOf({ $0.identifier.UUIDString == identifierString }) else {
            return nil
        }
        
        return managedPeripherals[index]
    }
    
    func scan(withServices serviceUUIDs: [CBUUID]? = nil,
                           options: [String : AnyObject]? = nil,
                           allowDuplicatePeripheralIds: Bool = false,
                           timeout: NSTimeInterval = 10,
                           validatePeripheralPredicate: BTCentralManagerScanningOperation.BTScanningValidPeripheralPredicate? = nil,
                           stopScanningCondition: BTCentralManagerScanningOperation.BTScanningStopBlock)
        -> SignalProducer<[BTPeripheral], BTError> {
            
            return SignalProducer { observer, disposable in
                let startScanningOperation = BTCentralManagerScanningOperation(
                    centralManager: self.centralManager,
                    serviceUUIDs: serviceUUIDs,
                    options: options,
                    allowDuplicatePeripheralIds: allowDuplicatePeripheralIds,
                    timeout: timeout,
                    intermediateScanResultBlock: {
                        [weak self] (discoveredPeripherals: [BTPeripheralAPIType]) in
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        for discoveredPeripheral in discoveredPeripherals {
                             strongSelf.updateManagedPeripheral(discoveredPeripheral)
                        }
                        
                        let modelPeripherals = discoveredPeripherals.map {
                            BTCentralRolePerformer.modelPeripheralWithScannedPeripheral($0)
                        }
                        
                        for modelPeripheral in modelPeripherals {
                            strongSelf.updateModelPeripheral(modelPeripheral)
                        }
                        
                        observer.sendNext(modelPeripherals)
                    },
                    stopScanningCondition: stopScanningCondition)
                
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
                            Log.bluetooth.error("BTCentralRolePerformer: scanning, error: \(error)")
                            observer.sendFailed(error)
                            return
                        }
                    }
                    
                    guard let scanningOperation = operation as? BTCentralManagerScanningOperation else {
                        let error = BTOperationError(code: .OperationTypeMismatch)
                        Log.bluetooth.error("BTCentralRolePerformer: scanning, error: \(error)")
                        observer.sendFailed(error)
                        return
                    }
                    
                    Log.bluetooth.info("BTCentralRolePerformer: scan completed, " +
                        "discovered peripherals: \(scanningOperation.discoveredPeripherals)")
                    
                    for discoveredPeripheral in scanningOperation.discoveredPeripherals {
                        strongSelf.updateManagedPeripheral(discoveredPeripheral)
                    }

                    let modelPeripherals = scanningOperation.discoveredPeripherals.map {
                        BTCentralRolePerformer.modelPeripheralWithScannedPeripheral($0)
                    }
                    
                    for modelPeripheral in modelPeripherals {
                        strongSelf.updateModelPeripheral(modelPeripheral)
                    }
                    
                    observer.sendNext(modelPeripherals)
                    observer.sendCompleted()
                })
                
                self.scanOperation = startScanningOperation
                
                self.operationQueue.addOperation(startScanningOperation)
            }
    }
    
    func stopScan() {
        scanOperation?.cancel()
        scanOperation = nil
    }
    
    func connectSignalProviderWithPeripheral(peripheral: BTPeripheralAPIType,
                 options: [String : AnyObject]? = nil) -> BTPeripheralConnectSignalProvider {
        return BTPeripheralConnectSignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            options: options,
            centralRolePerformer: self)
    }
    
    func disconnectSignalProviderWithPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheralDisconnectSignalProvider {
        return BTPeripheralDisconnectSignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            centralRolePerformer: self)
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTCentralRolePerformer: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 willRestoreState dict: [String : AnyObject]) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didConnectPeripheral peripheral: BTPeripheralAPIType) {
        peripheral.addHandler(self)
        peripheral.addHandler(BTPeripheralLoggingHandler())
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                                         error: NSError?) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didFailToConnectPeripheral peripheral: BTPeripheralAPIType,
                                                            error: NSError?) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didDiscoverPeripheral peripheral: BTPeripheralAPIType,
                                                       advertisementData: [String : AnyObject],
                                                       RSSI: NSNumber) {
        // Nothing to do here
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTCentralRolePerformer: BTPeripheralHandlerProtocol {
    
    func peripheralDidUpdateName(peripheral: BTPeripheralAPIType) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didDiscoverServices error: NSError?) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didDiscoverCharacteristicsForService service: CBService,
                                                                  error: NSError?) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didUpdateValueForCharacteristic characteristic: CBCharacteristic,
                                                             error: NSError?) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didWriteValueForCharacteristic characteristic: CBCharacteristic,
                                                            error: NSError?) {
    }
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
                                                    error: NSError?) {
    }
}

// MARK: Supporting Methods

private extension BTCentralRolePerformer {
    static func modelPeripheralWithScannedPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheral {
        return BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                            name: peripheral.name,
                            state: .Scanned)
    }
    
    static func modelPeripheralWithConnectedPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheral {
        return BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                            name: peripheral.name,
                            state: .Connected)
    }
}
