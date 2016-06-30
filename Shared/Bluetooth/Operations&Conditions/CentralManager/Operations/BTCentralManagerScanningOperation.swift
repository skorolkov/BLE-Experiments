//
//  BTCentralManagerScanningOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

typealias BTPeripheralScanResult = (
    peripheral: BTPeripheralAPIType,
    advertisementData: [String : AnyObject],
    RSSI: NSNumber)

class BTCentralManagerScanningOperation: BTCentralManagerOperation {
    
    typealias BTScanningResultBlock = (discoveryResults: [BTPeripheralScanResult]) -> Void
    typealias BTScanningStopBlock = (discoveryResults: [BTPeripheralScanResult]) -> Bool
    typealias BTScanningValidPeripheralPredicate = (discoveryResult: BTPeripheralScanResult) -> Bool

    // MARK: Private Properties
    
    private var serviceUUIDs: [CBUUID]? = nil
    private var options: [String : AnyObject]? = nil
    private var allowDuplicatePeripheralIds: Bool
    private var validatePeripheralPredicate: BTScanningValidPeripheralPredicate? = nil
    private var intermediateScanResultBlock: BTScanningResultBlock? = nil
    private var stopScanningCondition: BTScanningStopBlock
    
    private(set) var discoveryResults: [BTPeripheralScanResult] = []
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         serviceUUIDs: [CBUUID]? = nil,
         options: [String : AnyObject]? = nil,
         allowDuplicatePeripheralIds: Bool = false,
         timeout: NSTimeInterval = 10,
         validatePeripheralPredicate: BTScanningValidPeripheralPredicate? = nil,
         intermediateScanResultBlock: BTScanningResultBlock? = nil,
         stopScanningCondition: BTScanningStopBlock,
         mutuallyExclusiveCondition: OperationCondition = MutuallyExclusive<BTCentralManagerScanningOperation>()) {
        self.serviceUUIDs = serviceUUIDs
        self.options = options
        self.allowDuplicatePeripheralIds = allowDuplicatePeripheralIds
        self.validatePeripheralPredicate = validatePeripheralPredicate
        self.intermediateScanResultBlock = intermediateScanResultBlock
        self.stopScanningCondition = stopScanningCondition
        
        super.init(centralManager: centralManager)
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
        addCondition(mutuallyExclusiveCondition)
        
        addObserver(TimeoutObserver(timeout: timeout))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        
        centralManager?.scanForPeripheralsWithServices(serviceUUIDs,
                                                       options: options)
    }

    override func cancel() {
        centralManager?.stopScan()
        centralManager?.removeHandler(self)
        super.cancel()
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
        
        if !allowDuplicatePeripheralIds {
            if let _ = discoveryResults.indexOf({
                return $0.peripheral.identifier.isEqual(peripheral.identifier) }) {
                return
            }
        }
        
        let discoveryResult = BTPeripheralScanResult(
            peripheral: peripheral,
            advertisementData: advertisementData,
            RSSI: RSSI)
        
        if let predicate = validatePeripheralPredicate {
            if predicate(discoveryResult: discoveryResult) {
                newPeripheralDiscovered(discoveryResult)
            }
        }
        else {
            newPeripheralDiscovered(discoveryResult)
        }
    }
}

// MARK: Supporting Methdods

private extension BTCentralManagerScanningOperation {
    func newPeripheralDiscovered(discoveryResult: BTPeripheralScanResult) {
        
        discoveryResults.append(discoveryResult)
        intermediateScanResultBlock?(discoveryResults: discoveryResults)
        
        if stopScanningCondition(discoveryResults: discoveryResults) {
            centralManager?.stopScan()
            removeHandlerAndFinish()
        }
    }
}
