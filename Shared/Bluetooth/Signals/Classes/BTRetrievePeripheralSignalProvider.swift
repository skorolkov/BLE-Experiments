//
//  BTRetrievePeripheralSignalProvider.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

class BTRetrievePeripheralSignalProvider {
    
    // MARK: Privare Properties
    
    private let centralManager: BTCentralManagerAPIType
    private let periphralUUIDs: [NSUUID]
    private let centralRolePerformer: BTCentralRolePerforming
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         periphralUUIDs: [NSUUID],
         centralRolePerformer: BTCentralRolePerforming) {
        self.centralManager = centralManager
        self.periphralUUIDs = periphralUUIDs
        self.centralRolePerformer = centralRolePerformer
    }
    
    // MARK: Internal Methods
    
    func retrieve() -> SignalProducer<[BTPeripheral], NoError> {
        return SignalProducer { observer, disposable in
            let peripherals = self.centralManager.retrievePeripheralsWithIdentifiers(self.periphralUUIDs)
            let peripheralProxies = peripherals.map { BTPeripheralProxy(peripheral: $0) }
            
            for peripheralProxy in peripheralProxies {
                self.centralRolePerformer.updateManagedPeripheral(peripheralProxy)
            }
            
            let modelPeripherals = peripheralProxies.map { BTPeripheral.createWithRetrievedPeripheral($0) }
            
            for modelPeripheral in modelPeripherals {
                self.centralRolePerformer.updateModelPeripheral(modelPeripheral)
            }
            
            observer.sendNext(modelPeripherals)
            observer.sendCompleted()
        }
    }
}
