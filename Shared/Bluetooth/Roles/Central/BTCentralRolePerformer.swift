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
    
    func scanSignalProvider(withServices serviceUUIDs: [CBUUID]? = nil,
                                         options: [String : AnyObject]? = nil,
                                         allowDuplicatePeripheralIds: Bool = false,
                                         timeout: NSTimeInterval = 10,
                                         validatePeripheralPredicate: BTCentralManagerScanningOperation.BTScanningValidPeripheralPredicate? = nil,
                                         stopScanningCondition: BTCentralManagerScanningOperation.BTScanningStopBlock) -> BTPeripheralScanSignalProvider {
        
        return BTPeripheralScanSignalProvider(
            centralManager: centralManager,
            serviceUUIDs: serviceUUIDs,
            options: options,
            allowDuplicatePeripheralIds: allowDuplicatePeripheralIds,
            timeout: timeout,
            validatePeripheralPredicate: validatePeripheralPredicate,
            stopScanningCondition: stopScanningCondition,
            centralRolePerformer: self)
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
    
    func discoverCharacteristicsSignalProviderWithPeripheral(
        peripheral: BTPeripheralAPIType,
        servicePrototypes: [BTService]) -> BTPeripheralCharacteristicDiscoverySignalProvider {
        return BTPeripheralCharacteristicDiscoverySignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            servicePrototypes: servicePrototypes,
            centralRolePerformer: self)
    }
    
    func discoverCharacteristicsSignalProviderWithPeripheral(
        peripheral: BTPeripheralAPIType,
        characteristicPrototypes: [BTCharacteristic]) -> BTPeripheralCharacteristicDiscoverySignalProvider {
        return BTPeripheralCharacteristicDiscoverySignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            characteristicPrototypes: characteristicPrototypes,
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
}
