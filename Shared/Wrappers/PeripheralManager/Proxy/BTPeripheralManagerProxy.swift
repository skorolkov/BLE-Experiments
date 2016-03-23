//
//  BTPeripheralManagerProxy.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc class BTPeripheralManagerProxy: NSObject {
    
    // MARK: Private Properties
    
    private var peripheralManager: BTPeripheralManagerInitializibleType
    
    private var handlers: [BTPeripheralManagerHandlerProtocol] = []
    
    // MARK: Initializers
    
    init(peripheralManager: BTPeripheralManagerInitializibleType) {
        self.peripheralManager = peripheralManager
        super.init()
        
        self.peripheralManager.delegate = self
    }
}

// MARK: BTPeripheralManagerAPIProtocol

extension BTPeripheralManagerProxy: BTPeripheralManagerAPIProtocol {
    
    // MARK: State
    
    var state: CBPeripheralManagerState {
        return peripheralManager.state
    }
    
    // MARK: Start/Stop Advertising
    
    func startAdvertising(advertisementData: [String : AnyObject]?) {
        peripheralManager.startAdvertising(advertisementData)
    }
    
    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }
    
    // MARK: Manage Serives
    
    func addService(service: CBMutableService) {
        peripheralManager.addService(service)
    }
    
    func removeService(service: CBMutableService) {
        peripheralManager.removeService(service)
    }
    
    func removeAllServices() {
        peripheralManager.removeAllServices()
    }
    
    // MARK: Responding To Requests
    
    func respondToRequest(request: CBATTRequest, withResult result: CBATTError) {
        peripheralManager.respondToRequest(request, withResult: result)
    }
    
    // MARK: Update Value for characteristic
    
    func updateValue(value: NSData,
        forCharacteristic characteristic: CBMutableCharacteristic,
        onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
        return peripheralManager.updateValue(value,
            forCharacteristic: characteristic,
            onSubscribedCentrals: centrals)
    }
}

// MARK: BTPeripheralManagerAPIWithHadlerProtocol

extension BTPeripheralManagerProxy: BTPeripheralManagerAPIWithHadlerProtocol {
    
    func addHandler(handlerToAdd: BTPeripheralManagerHandlerProtocol) {
        guard indexOfHandler(handlerToAdd) == nil else {
            return
        }
        
        handlers.append(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTPeripheralManagerHandlerProtocol) {
        guard let index = indexOfHandler(handlerToRemove) else {
            return
        }
        
        handlers.removeAtIndex(index)
    }
    
    private func indexOfHandler(handlerToFind: BTPeripheralManagerHandlerProtocol) -> Int? {
        return handlers.indexOf { (handler: BTPeripheralManagerHandlerProtocol) -> Bool in
            return handler.isEqual(handlerToFind)
        }
    }
}

extension BTPeripheralManagerProxy: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManagerDidUpdateState(wrappedPeripheralManager(peripheral))
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManagerDidStartAdvertising?(wrappedPeripheralManager(peripheral), error: error)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManager?(wrappedPeripheralManager(peripheral),
                didAddService: service,
                error: error)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManager?(wrappedPeripheralManager(peripheral),
                didReceiveReadRequest: request)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManager?(wrappedPeripheralManager(peripheral),
                didReceiveWriteRequests: requests)
        }
    }
}

// MARK: Supporting methods

private extension BTPeripheralManagerProxy {
    func wrappedPeripheralManager(centralManager: CBPeripheralManager) -> BTPeripheralManagerAPIType {
        return self
    }
}
