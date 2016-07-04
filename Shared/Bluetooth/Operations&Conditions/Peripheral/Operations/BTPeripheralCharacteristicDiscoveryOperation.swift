//
//  BTPeripheralCharacteristicDiscoveryOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/11/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

class BTPeripheralCharacteristicDiscoveryOperation: BTPeripheralOperation {
    
    // MARK: Internal Properties
    
    private(set) var updatedPeripheral: BTPeripheralAPIType? = nil
    
    // MARK: Private Properties

    private let core: BTCharacteristicDiscoveryCore
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         servicePrototypes: [BTServicePrototype] = []) {
        
        self.core = BTCharacteristicDiscoveryCore(servicePrototypes: servicePrototypes)
        
        super.init(centralManager: centralManager,
                   peripheral: peripheral)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
        addCondition(BTPeripheralConnectedCondition(peripheral: peripheral))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        peripheral?.addHandler(self)
        
        peripheral?.discoverServices(core.serviceUUIDs)
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTPeripheralCharacteristicDiscoveryOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(
        central: BTCentralManagerAPIType,
        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                error: NSError?) {
        
        let btError: ErrorType? = (error != nil) ?
            BTCentralManagerDidDisconnectPeripheralError(originalError: error) : nil
        removeHandlerAndFinish(btError)
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTPeripheralCharacteristicDiscoveryOperation: BTPeripheralHandlerProtocol {
    
    func peripheral(peripheral: BTPeripheralAPIType,
                    didDiscoverServices error: NSError?) {
        
        if let originalError = error {
            let btError = BTPeriphalServiceDiscoveryError(originalError: originalError)
            removeHandlerAndFinish(btError)
            return
        }
        
        guard let services = peripheral.services else {
            updatedPeripheral = peripheral
            removeHandlerAndFinish()
            return
        }
        
        let itemsToDiscover = core.discoveredServices(services)
        
        guard !itemsToDiscover.isEmpty else {
            updatedPeripheral = peripheral
            removeHandlerAndFinish()
            return
        }
        
        itemsToDiscover.forEach { (service, characteristicUUIDs) in
            peripheral.discoverCharacteristics(characteristicUUIDs, forService: service)
        }
    }
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didDiscoverCharacteristicsForService service: CBService,
                                             error: NSError?) {
        
        
        let discoveryFinished = core.discoveredCharacteristicsForService(service, error: error)
        
        if discoveryFinished {
            updatedPeripheral = peripheral
            removeHandlerAndFinish()
        }
    }
}
