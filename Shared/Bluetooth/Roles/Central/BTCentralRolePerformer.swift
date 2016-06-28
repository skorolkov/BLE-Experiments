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

class BTCentralRolePerformer: NSObject {
    
    // MARK: Singleton

    static let sharedInstance = BTCentralRolePerformer()

    // MARK: Signals
    
    typealias BTPeripheralNotifier = protocol<BTPeripheralUpdating, NSObjectProtocol>
    
    private(set) var peripheralDataProvider: BTPeripheralDataProvider = BTPeripheralDataProvider()
    
    private var peripheralNotifier: BTPeripheralNotifier {
        return peripheralDataProvider
    }
    
    // MARK: Private Properties
    
    private var centralManager: BTCentralManagerAPIWithHadlerProtocol
    
    private var scannedPeripherals: [BTPeripheralAPIType] = [] {
        didSet {
            let modelPeripherals = BTCentralRolePerformer.modelPeripheralsFromScannedPeripherals(scannedPeripherals)
            peripheralNotifier.scannedPeripheralsToUpdate.value = modelPeripherals
        }
    }
    
    private var managedPeripherals: [BTPeripheralAPIType] = []
    
    // MARK: Operations
    
    private var operationQueue: OperationQueue
    private var scanOperation: BTCentralManagerScanningOperation? = nil

    // MARK: Initializers
    
    override init() {
        
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
                        
                        strongSelf.scannedPeripherals = discoveredPeripherals
                        
                        let modelPeripherals = BTCentralRolePerformer.modelPeripheralsFromScannedPeripherals(discoveredPeripherals)
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
                    
                    strongSelf.scannedPeripherals = scanningOperation.discoveredPeripherals
                    
                     Log.bluetooth.info("BTCentralRolePerformer: scan completed, " +
                        "discovered periphrals: \(strongSelf.scannedPeripherals)")
                    
                    let modelPeripherals =
                        BTCentralRolePerformer.modelPeripheralsFromScannedPeripherals(strongSelf.scannedPeripherals)
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
    static func modelPeripheralsFromScannedPeripherals(peripherals: [BTPeripheralAPIType]) -> [BTPeripheral] {
        return peripherals.map { return BTCentralRolePerformer.modelPeripheralWithScannedPeripheral($0) }
    }
    
    static func modelPeripheralWithScannedPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheral {
        return BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                            name: peripheral.name,
                            state: .Scanned)
    }
}
