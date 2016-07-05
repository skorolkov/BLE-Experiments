//
//  BTRetrieveConnectedPeripheralSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import Result

class BTRetrieveConnectedPeripheralSignalProvider {
    
    // MARK: Privare Properties
    
    private let centralManager: BTCentralManagerAPIType
    private let serviceUUIDs: [CBUUID]
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         serviceUUIDs: [CBUUID],
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.serviceUUIDs = serviceUUIDs
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Internal Methods
    
    func retrieveСonnected() -> SignalProducer<[BTPeripheral], NoError> {
        return SignalProducer { observer, disposable in
            let peripherals = self.centralManager.retrieveConnectedPeripheralsWithServices(self.serviceUUIDs)
            let peripheralProxies = peripherals.map { BTPeripheralProxy(peripheral: $0) }
            
            for peripheralProxy in peripheralProxies {
                self.centralRolePerformer.updateManagedPeripheral(peripheralProxy)
            }
            
            let modelPeripherals = peripheralProxies.map { BTPeripheral.createWithRetrieveConnectedPeripheral($0) }
            
            for modelPeripheral in modelPeripherals {
                self.centralRolePerformer.updateModelPeripheral(modelPeripheral)
            }
            
            observer.sendNext(modelPeripherals)
            observer.sendCompleted()
        }
    }
}
