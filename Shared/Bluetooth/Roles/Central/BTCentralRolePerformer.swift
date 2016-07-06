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
    private var scanningForPeripherals: Bool = false {
        didSet {
            peripheralNotifier.scanningForPeripheralsToUpdate.value = scanningForPeripherals
        }
    }
    
    // MARK: Operations
    
    private(set) var operationQueue: OperationQueue
    
    // MARK: Central Manager
    
    private var centralManager: BTCentralManagerAPIWithHadlerProtocol!
    
    // MARK: Initializers
    
    override init() {
        
        // WARNING: the same dispatch_queue used for OperationQueue and for CBCentralManager
        let queueName = "com.bluetooth.\(self.dynamicType)"
        let queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT)
        
        operationQueue = OperationQueue()
        operationQueue.name = queueName
        operationQueue.underlyingQueue = queue
        
        super.init()
        
        let bluetoothCentralManager = CBCentralManager(
            delegate: nil,
            queue: queue,
            options: [CBCentralManagerOptionShowPowerAlertKey : true])
        
        centralManager = BTCentralManagerProxy(centralManager: bluetoothCentralManager, peripheralWrapper: self)
        
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
    
    func updateModelPeripheral(modelPeripheral: BTPeripheral) {
        if let index = modelPeripherals.indexOf( { $0.identifierString == modelPeripheral.identifierString } ) {
            modelPeripherals[index] = modelPeripheral
        }
        else {
            modelPeripherals.append(modelPeripheral)
        }
    }
    
    func modelPeripheralWithIdentifier(identifierString: String) -> BTPeripheral? {
        guard let index = modelPeripherals.indexOf({ $0.identifierString == identifierString }) else {
            return nil
        }
        
        return modelPeripherals[index]
    }
    
    func removeNotUsedModelPeripherals() {
        let usedModelPeripherals = modelPeripherals.filter {
            $0.state == .Connected || $0.state == .CharacteristicDiscovered
        }
        
        modelPeripherals = usedModelPeripherals
    }
    
    func setScanningForPeripheralsInProgress(scanningInProgress: Bool) {
        self.scanningForPeripherals = scanningInProgress
    }
    
    // MARK: Get Peripheral
    
    func peripheralWithIdentifier(identifierString: String) -> BTPeripheralAPIType? {
        guard let index = managedPeripherals.indexOf({ $0.identifier.UUIDString == identifierString }) else {
            return nil
        }
        
        return managedPeripherals[index]
    }

    // MARK: Get Signal Providers
    
    func scanSignalProvider(withServices serviceUUIDs: [CBUUID]? = nil,
                                         options: [String : AnyObject]? = nil,
                                         allowDuplicatePeripheralIds: Bool = false,
                                         cleanNotUsedPeripherals: Bool = true,
                                         timeout: NSTimeInterval = 10,
                                         validatePeripheralPredicate: BTCentralManagerScanningOperation.BTScanningValidPeripheralPredicate? = nil,
                                         stopScanningCondition: BTCentralManagerScanningOperation.BTScanningStopBlock) -> BTPeripheralScanSignalProvider {
        
        return BTPeripheralScanSignalProvider(
            centralManager: centralManager,
            serviceUUIDs: serviceUUIDs,
            options: options,
            allowDuplicatePeripheralIds: allowDuplicatePeripheralIds,
            cleanNotUsedPeripherals: cleanNotUsedPeripherals,
            timeout: timeout,
            validatePeripheralPredicate: validatePeripheralPredicate,
            stopScanningCondition: stopScanningCondition,
            centralRolePerformer: self)
    }
    
    func retrievePeripheralWithUUIDs(periphralUUIDs: [NSUUID]) -> BTRetrievePeripheralSignalProvider {
        return BTRetrievePeripheralSignalProvider(
            centralManager: self.centralManager,
            periphralUUIDs: periphralUUIDs,
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
    
    func retrieveConnectedPeripheralWithServiceUUIDs(serviceUUIDs: [CBUUID]) -> BTRetrieveConnectedPeripheralSignalProvider {
        return BTRetrieveConnectedPeripheralSignalProvider(
            centralManager: self.centralManager,
            serviceUUIDs: serviceUUIDs,
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
        servicePrototypes: [BTServicePrototype]) -> BTPeripheralCharacteristicDiscoverySignalProvider {
        return BTPeripheralCharacteristicDiscoverySignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            servicePrototypes: servicePrototypes,
            centralRolePerformer: self)
    }
    
    func notificationsEnabledValueUpdateSignalProvider(
        notificationsEnabled: Bool,
        peripheral: BTPeripheralAPIType,
        characteristic: CBCharacteristic) -> BTCharacteristicSetNotifyValueSignalProvider {
        return BTCharacteristicSetNotifyValueSignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            characterictic: characteristic,
            notificationsEnabled: notificationsEnabled,
            centralRolePerformer: self)
    }
    
    func readValueForCharacteristic(
        characteristic: CBCharacteristic,
        peripheral: BTPeripheralAPIType) -> BTReadCharacteristicSignalProvider {
        return BTReadCharacteristicSignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            characterictic: characteristic,
            centralRolePerformer: self)
    }
    
    func writeValue(
        value: NSData,
        forCharacteristic characteristic: CBCharacteristic,
                          writeType: CBCharacteristicWriteType = .WithResponse,
                          peripheral: BTPeripheralAPIType) -> BTWriteCharacteristicSignalProvider {
        return BTWriteCharacteristicSignalProvider(
            centralManager: centralManager,
            peripheral: peripheral,
            valueToWrite: value,
            charactericticToWrite: characteristic,
            writeType: writeType,
            centralRolePerformer: self)
    }
}

// MARK: BTCentralManagerPeripheralWrappingProtocol

extension BTCentralRolePerformer: BTCentralManagerPeripheralWrappingProtocol {
    func wrappedPeripheral(peripheral: CBPeripheral) -> BTPeripheralAPIType? {
        guard let index = managedPeripherals.indexOf( { $0.identifier.isEqual(peripheral.identifier) } ) else {
            return nil
        }
        
        return managedPeripherals[index]
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTCentralRolePerformer: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        peripheralNotifier.centralManagerStateToUpdate.value = central.state
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        willRestoreState dict: [String : AnyObject]) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didConnectPeripheral peripheral: BTPeripheralAPIType) {
        peripheral.addHandler(self)
        peripheral.addHandler(BTPeripheralLoggingHandler())
        
        updateManagedPeripheral(peripheral)
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                                error: NSError?) {
        
        updateManagedPeripheral(peripheral)
        let modelPeripheral = BTPeripheral.createWithDisconnectedPeripheral(peripheral, error: error)
        updateModelPeripheral(modelPeripheral)
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
        if let index = modelPeripherals.indexOf( { $0.identifierString == peripheral.identifier.UUIDString } ) {
            let previousModelPeripheral = modelPeripherals[index]
            let newModelPeripheral = BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                                                  name: peripheral.name,
                                                  state: previousModelPeripheral.state)
            modelPeripherals[index] = newModelPeripheral
        }
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                    didDiscoverServices error: NSError?) {
        // Nothing to do here
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                    didDiscoverCharacteristicsForService service: CBService,
                                                         error: NSError?) {
        // Nothing to do here
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                    didUpdateValueForCharacteristic characteristic: CBCharacteristic,
                                                    error: NSError?) {
        updateModelPeripheral(peripheral, withCharacteristic: characteristic)
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                    didWriteValueForCharacteristic characteristic: CBCharacteristic,
                                                   error: NSError?) {
        // Nothing to do here
    }
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
                                                    error: NSError?) {
        updateModelPeripheral(peripheral, withCharacteristic: characteristic)
    }
}

// MARK: Supporting Methods

private extension BTCentralRolePerformer {
    func updateModelPeripheral(
            peripheral: BTPeripheralAPIType,
            withCharacteristic characteristic: CBCharacteristic) {

        let modelCharacteristic = BTCharacteristic(coreBluetoothCharacteristic: characteristic)

        if let index = modelPeripherals.indexOf({ $0.identifierString == peripheral.identifier.UUIDString }) {
            let previousModelPeripheral = modelPeripherals[index]
            let newModelPeripheral = BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                                                  name: peripheral.name,
                                                  state: previousModelPeripheral.state,
                                                  characteristics: [modelCharacteristic])
            modelPeripherals[index] = newModelPeripheral
        }
        else {
            let newModelPeripheral = BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                                                  name: peripheral.name,
                                                  state: .Unknown,
                                                  characteristics: [modelCharacteristic])
            modelPeripherals.append(newModelPeripheral)
        }
    }
}
