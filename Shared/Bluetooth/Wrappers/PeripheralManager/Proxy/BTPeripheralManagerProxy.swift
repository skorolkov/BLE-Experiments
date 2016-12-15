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
    
    private var handlerContainer = BTHandlersContainer<BTPeripheralManagerHandlerProtocol>()
    
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
    
    var managerState: BTManagerState {
        return peripheralManager.managerState
    }
    
    // MARK: Advertising state
    
    var isAdvertising: Bool {
        return peripheralManager.isAdvertising
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
        handlerContainer.addHandler(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTPeripheralManagerHandlerProtocol) {
        handlerContainer.removeHandler(handlerToRemove)
    }
}

extension BTPeripheralManagerProxy: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        handlerContainer.handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManagerDidUpdateState(wrappedPeripheralManager(peripheral))
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        handlerContainer.handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManagerDidStartAdvertising?(wrappedPeripheralManager(peripheral), error: error)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        handlerContainer.handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManager?(wrappedPeripheralManager(peripheral),
                didAddService: service,
                error: error)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        handlerContainer.handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
            handler.peripheralManager?(wrappedPeripheralManager(peripheral),
                didReceiveReadRequest: request)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        handlerContainer.handlers.forEach { (handler: BTPeripheralManagerHandlerProtocol) -> () in
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
