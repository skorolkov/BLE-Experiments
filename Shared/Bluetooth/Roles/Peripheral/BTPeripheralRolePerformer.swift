//
//  BTPeripheralRolePerformer.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/21/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import CocoaLumberjack
import Operations

class BTPeripheralRolePerformer: NSObject {
    
    // MARK: Types Definitions
    
    typealias BTPeripheralRoleBlock =
        (rolePerformer: BTPeripheralRolePerformer, result: BTOperationResult) -> Void
    
    // MARK: Private Properties

    private var peripheralManager: BTPeripheralManagerProxy

    private(set) var services: [BTPrimacyService] = []
    private(set) var advertisementData: [String : AnyObject] = [:]
    private(set) var servicesAdded: Bool = false
    
    // MARK: Operations
    
    private var operationQueue: OperationQueue
    
    // MARK: Initializers
    
    init(services: [BTPrimacyService],
         advertisementData: [String : AnyObject]) {
        
        operationQueue = OperationQueue()
        operationQueue.name = "\(self.dynamicType).queue"
        
        let bluetoothPeripheralManager = CBPeripheralManager(
            delegate: nil,
            queue: nil,
            options: [CBPeripheralManagerOptionShowPowerAlertKey : true])
        
        peripheralManager = BTPeripheralManagerProxy(peripheralManager: bluetoothPeripheralManager)
        
        self.services = services
        self.advertisementData = advertisementData
        
        super.init()
        
        peripheralManager.addHandler(self)
        peripheralManager.addHandler(BTPeripheralManagerLoggingHandler())
    }
    
    convenience override init() {
        
        let characteristics = [
            BTPermissionsCharacteristic(UUIDString: "2A4D",
                properties: [.WriteWithoutResponse, .Write],
                permissions: .Writeable,
                value: nil),
            BTPermissionsCharacteristic(UUIDString: "2AAF",
                properties: .Notify,
                permissions: .Readable,
                value: nil)
        ]
        
        let mainService = BTPrimacyService(UUIDString: "C14D2C0A-401F-B7A9-841F-E2E93B80F631",
            primary: false,
            permissionCharacteristics: characteristics)
        
        let advertisementData = [
            CBAdvertisementDataLocalNameKey : "MyAwesomePeripheral",
            CBAdvertisementDataServiceUUIDsKey : [mainService.UUID]
        ]
    
        self.init(services: [mainService],
                  advertisementData: advertisementData)
    }
    
    // MARK: Internal Methods

    func startAdevertisingWithCompletion(completion: BTPeripheralRoleBlock?) -> BTPeripheralManagerOperation {
        
        let startAdvertisingOperation = BTStartAdvertisingOperation(
            peripheralManager: peripheralManager,
            peripheralRolePerformer: self)
        
        startAdvertisingOperation.advertisingData = advertisementData
        
        startAdvertisingOperation.addObserver(DidFinishObserver { (operation, errors) in
            
            Log.bluetooth.info("BTPeripheralRolePerformer: advertisement started")
            Log.bluetooth.verbose("BTPeripheralRolePerformer: advertisement start operation finished: " +
                "\(operation.finished) with errors: \(errors)")
            
            completion?(rolePerformer: self,
                result: BTOperationResult(operation: operation, errors: errors))
            })
        
        operationQueue.addOperation(startAdvertisingOperation)
        
        return startAdvertisingOperation
    }
    
    func stopAdevertising() {
        if peripheralManager.isAdvertising {
            peripheralManager.stopAdvertising()
            Log.bluetooth.info("BTPeripheralRolePerformer: advertisement stopped")
        }
    }
}

// MARK: BTPeripheralManagerHandlerProtocol

extension BTPeripheralRolePerformer: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        addServices()
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didAddService service: CBService, error: NSError?) {
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: BTPeripheralManagerAPIType, error: NSError?) {
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didReceiveReadRequest request: CBATTRequest) {
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didReceiveWriteRequests requests: [CBATTRequest]) {
    }
}

// MARK: Private methods

private extension BTPeripheralRolePerformer {
    func addServices() {
        let addServiceOperation = BTAddServicesOperation(withPeripheralManager: peripheralManager,
            peripheralRolePerformer: self,
            services: services)
        
        addServiceOperation.addObserver(DidFinishObserver { [weak weakSelf = self] (operation, errors) in
            
            if operation.finished && errors.isEmpty {
                weakSelf?.servicesAdded = true
                Log.bluetooth.info("BTPeripheralRolePerformer: services added")
            }
            
            Log.bluetooth.verbose("BTPeripheralRolePerformer: services add operation finished=" +
                "\(operation.finished), cancelled=\(operation.cancelled) with errors: \(errors)")
            })
        
        operationQueue.addOperation(addServiceOperation)
    }
}
