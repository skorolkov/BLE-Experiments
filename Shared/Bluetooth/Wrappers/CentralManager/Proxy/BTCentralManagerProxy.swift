//
//  CentralManagerProxy.swift
//  BLE-Experiments
//
//  Created by d503 on 3/7/16.
//
//

import Foundation
import CoreBluetooth

/**
 * Some methods of CentralManagerHandlerProtocol are optional, so class should be declared as @objc class,
 * and (as required by usage of '@objc' directive) it must inherit NSObject class
 */
@objc class BTCentralManagerProxy: NSObject {
    
    // MARK: Private Properties
    
    private var centralManager: BTCentralManagerInitializibleType
    private weak var peripheralWrapper: BTCentralManagerPeripheralWrappingProtocol?
    
    private var handlersContainer = BTHandlersContainer<BTCentralManagerHandlerProtocol>()
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerInitializibleType,
         peripheralWrapper: BTCentralManagerPeripheralWrappingProtocol) {
        self.centralManager = centralManager
        self.peripheralWrapper = peripheralWrapper
        super.init()
        
        self.centralManager.delegate = self
    }
    
    init<T where T: BTCentralManagerInitializibleType>(
        centralManagerType: T,
        peripheralWrapper: BTCentralManagerPeripheralWrappingProtocol,
        queue: dispatch_queue_t? = nil,
        centralManagerOptions options: [String : AnyObject]? = nil) {
            
            self.centralManager = T(delegate: nil, queue: queue, options: options)
            self.peripheralWrapper = peripheralWrapper
        
            super.init()
            
            self.centralManager.delegate = self
    }
}

// MARK: BTCentralManagerAPIProtocol

extension BTCentralManagerProxy: BTCentralManagerAPIProtocol {
    // MARK: State
    
    var managerState: BTManagerState {
        return centralManager.managerState
    }
    
    // MARK: Scan for peripherals
    
    func scanForPeripheralsWithServices(serviceUUIDs: [CBUUID]?, options: [String : AnyObject]?) {
        centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: options)
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    // MARK: Retrieving peripherals
    
    func retrievePeripheralsWithIdentifiers(identifiers: [NSUUID]) -> [CBPeripheral] {
        return centralManager.retrievePeripheralsWithIdentifiers(identifiers)
    }
    
    func retrieveConnectedPeripheralsWithServices(serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
        return centralManager.retrieveConnectedPeripheralsWithServices(serviceUUIDs)
    }
    
    // MARK: Connecting to peripherals
    
    func connectPeripheralWithObject(peripheral: BTPeripheralAPIType, options: [String : AnyObject]?) {
        centralManager.connectPeripheralWithObject(peripheral, options: options)
    }
    
    // MARK: Disconnecting from peripherals
    
    func cancelPeripheralConnectionWithObject(peripheral: BTPeripheralAPIType) {
        centralManager.cancelPeripheralConnectionWithObject(peripheral)
    }
}

// MARK: BTCentralManagerAPIWithHadlerProtocol

extension BTCentralManagerProxy: BTCentralManagerAPIWithHadlerProtocol {
    
    func addHandler(handlerToAdd: BTCentralManagerHandlerProtocol) {
        handlersContainer.addHandler(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTCentralManagerHandlerProtocol) {
        handlersContainer.removeHandler(handlerToRemove)
    }
}

// MARK: CBCentralManagerDelegate

extension BTCentralManagerProxy: CBCentralManagerDelegate {
    
    // MARK: Monitoring Changes to the Central Manager’s State
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        handlersContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) -> () in
            handler.centralManagerDidUpdateState(wrappedCentralManager(central))
        }
    }
    
    func centralManager(central: CBCentralManager,
        willRestoreState dict: [String : AnyObject]) {
            handlersContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) -> () in
                handler.centralManager?(wrappedCentralManager(central), willRestoreState: dict)
            }
    }
    
    // MARK: Monitoring Connections with Peripherals
    
    func centralManager(central: CBCentralManager,
        didConnectPeripheral peripheral: CBPeripheral) {
            handlersContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) -> () in
                handler.centralManager?(wrappedCentralManager(central),
                    didConnectPeripheral: wrappedPeripheral(peripheral))
            }
    }
    
    func centralManager(central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: NSError?) {
            handlersContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) -> () in
                handler.centralManager?(wrappedCentralManager(central),
                    didDisconnectPeripheral: wrappedPeripheral(peripheral),
                    error: error)
            }
    }
    
    func centralManager(central: CBCentralManager,
        didFailToConnectPeripheral peripheral: CBPeripheral,
        error: NSError?) {
            handlersContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) -> () in
                handler.centralManager?(wrappedCentralManager(central),
                    didFailToConnectPeripheral: wrappedPeripheral(peripheral),
                    error: error)
            }
    }
    
    // MARK: Discovering and Retrieving Peripherals
    
    func centralManager(central: CBCentralManager,
        didDiscoverPeripheral peripheral: CBPeripheral,
        advertisementData: [String : AnyObject],
        RSSI: NSNumber) {
            handlersContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) -> () in
                handler.centralManager?(wrappedCentralManager(central),
                    didDiscoverPeripheral: wrappedPeripheral(peripheral),
                    advertisementData: advertisementData,
                    RSSI: RSSI)
            }
    }
}

// MARK: Supporting methods

private extension BTCentralManagerProxy {
    func wrappedCentralManager(centralManager: CBCentralManager) -> BTCentralManagerAPIType {
        return self
    }
    
    func wrappedPeripheral(peripheral: CBPeripheral) -> BTPeripheralAPIType {
        if let wrappedPeripheral = peripheralWrapper?.wrappedPeripheral(peripheral) {
            return wrappedPeripheral
        }
        else {
            return BTPeripheralProxy(peripheral: peripheral)
        }
    }
}
