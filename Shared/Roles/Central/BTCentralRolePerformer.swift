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

class BTCentralRolePerformer: NSObject {
    
    // MARK: Types Definitions
    
    typealias BTCentralRoleBlock =
        (rolePerformer: BTCentralRolePerformer, result: BTOperationResult) -> Void
    
    // MARK: Private Properties
    
    private var centralManager: BTCentralManagerAPIWithHadlerProtocol
    
    private var discoveredPeripherals: [BTPeripheralAPIType] = []
    
    // MARK: Operations
    
    private var operationQueue: OperationQueue

    // MARK: Initializers
    
    override init() {
        operationQueue = OperationQueue()
        operationQueue.name = "\(self.dynamicType).queue"
        
        let bluetoothCentralManager = CBCentralManager(
            delegate: nil,
            queue: nil,
            options: [CBCentralManagerOptionShowPowerAlertKey : true])
        
        centralManager = BTCentralManagerProxy(centralManager: bluetoothCentralManager)
        
        super.init()
        
        centralManager.addHandler(self)
        
        centralManager.addHandler(BTCentralManagerLoggingHandler())
    }
    
    // MARK: Internal Methods
    
    func startScanningWithCompletion(completion: BTCentralRoleBlock?) -> BTCentralManagerOperation {
        
        let startScanningOperation = BTCentralManagerScanningOperation(
            centralManager: centralManager,
            serviceUUIDs: nil,
            options: nil) { (discoveredPeripherals: [BTPeripheralAPIType]) -> Bool in
                // FIXME: temp condition
                return discoveredPeripherals.count >= 1
        }
        
        startScanningOperation.addObserver(DidFinishObserver { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            if let scanningOperation = result.operation as? BTCentralManagerScanningOperation {
                strongSelf.discoveredPeripherals = scanningOperation.discoveredPeripherals
                
                print(strongSelf.discoveredPeripherals)
            }
            
            completion?(rolePerformer: strongSelf,
                result: BTOperationResult(operation: result.operation, errors: result.errors))
            })
        
        operationQueue.addOperation(startScanningOperation)
        
        return startScanningOperation
    }
    
}

// MARK: BTCentralManagerHandlerProtocol

extension BTCentralRolePerformer: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 willRestoreState dict: [String : AnyObject]) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didConnectPeripheral peripheral: BTPeripheralAPIType) {
        peripheral.addHandler(self)
        peripheral.addHandler(BTPeripheralLoggingHandler())
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                                         error: NSError?) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didFailToConnectPeripheral peripheral: BTPeripheralAPIType,
                                                            error: NSError?) {
    }
    
    func centralManager(central: BTCentralManagerAPIType,
                                 didDiscoverPeripheral peripheral: BTPeripheralAPIType,
                                                       advertisementData: [String : AnyObject],
                                                       RSSI: NSNumber) {
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTCentralRolePerformer: BTPeripheralHandlerProtocol {
    
    func peripheralDidUpdateName(peripheral: BTPeripheralAPIType) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didDiscoverServices error: NSError?) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didDiscoverCharacteristicsForService service: CBService,
                                                                  error: NSError?) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didUpdateValueForCharacteristic characteristic: CBCharacteristic,
                                                             error: NSError?) {
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
                             didWriteValueForCharacteristic characteristic: CBCharacteristic,
                                                            error: NSError?) {
    }
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
                                                    error: NSError?) {
    }
}
