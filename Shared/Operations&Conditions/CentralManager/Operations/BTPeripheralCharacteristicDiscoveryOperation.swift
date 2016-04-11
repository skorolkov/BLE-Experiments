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
    
    private var servicesToDiscover: [BTService]? = nil
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         servicesToDiscover: [BTService]? = nil) {
        
        super.init(centralManager: centralManager,
                   peripheral: peripheral)
        
        self.servicesToDiscover = nil
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        peripheral?.addHandler(self)
        
        let serviceUUIDs = servicesToDiscover?.map { $0.UUID }
        
        peripheral?.discoverServices(serviceUUIDs)
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
            BTCentralManagerFailToConnectPeripheralError(originalError: error) : nil
        removeHandlerAndFinish(btError)
        
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTPeripheralCharacteristicDiscoveryOperation: BTPeripheralHandlerProtocol {
    
    func peripheral(peripheral: BTPeripheralAPIType,
                    didDiscoverServices error: NSError?) {
        
    }
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didDiscoverCharacteristicsForService service: CBService,
                                             error: NSError?) {
        
    }
}
