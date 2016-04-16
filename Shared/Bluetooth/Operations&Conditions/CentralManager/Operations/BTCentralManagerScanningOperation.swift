//
//  BTCentralManagerScanningOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

class BTCentralManagerScanningOperation: BTCentralManagerOperation {
    
    typealias BTStopScanningBlock = (discoveredPeripherals: [BTPeripheralAPIType]) -> Bool
    
    // MARK: Private Properties
    
    private var serviceUUIDs: [CBUUID]? = nil
    private var options: [String : AnyObject]? = nil
    private var stopScanningCondition: BTStopScanningBlock
    
    private(set) var discoveredPeripherals: [BTPeripheralAPIType] = []
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         serviceUUIDs: [CBUUID]? = nil,
         options: [String : AnyObject]? = nil,
         stopScanningCondition: BTStopScanningBlock) {
        self.serviceUUIDs = serviceUUIDs
        self.options = options
        self.stopScanningCondition = stopScanningCondition
        
        super.init(centralManager: centralManager)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
        addCondition(MutuallyExclusive<BTCentralManagerScanningOperation>())
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        
        centralManager?.scanForPeripheralsWithServices(serviceUUIDs,
                                                       options: options)
    }
}

extension BTCentralManagerScanningOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                        didDiscoverPeripheral peripheral: BTPeripheralAPIType,
                                              advertisementData: [String : AnyObject],
                                              RSSI: NSNumber) {
        discoveredPeripherals.append(peripheral)
        
        if stopScanningCondition(discoveredPeripherals: discoveredPeripherals) {
            centralManager?.stopScan()
            removeHandlerAndFinish()
        }        
    }
}
