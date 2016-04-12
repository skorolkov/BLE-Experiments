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
    private(set) var servicesAdded: Bool = false
    
    // MARK: Operations
    
    private var operationQueue: OperationQueue
    
    // MARK: Initializers
    
    init(services: [BTPrimacyService]) {
        
        operationQueue = OperationQueue()
        operationQueue.name = "\(self.dynamicType).queue"
        
        let bluetoothPeripheralManager = CBPeripheralManager(
            delegate: nil,
            queue: nil,
            options: [CBPeripheralManagerOptionShowPowerAlertKey : true])
        
        peripheralManager = BTPeripheralManagerProxy(peripheralManager: bluetoothPeripheralManager)
        
        self.services = services
        
        super.init()
        
        peripheralManager.addHandler(self)
    }
    
    convenience override init() {
        
        let characteristics = [
            BTPermissionsCharacteristic(UUIDString: "2A4D",
                propeties: [.WriteWithoutResponse, .Write],
                value: nil,
                permissions: .Writeable),
            BTPermissionsCharacteristic(UUIDString: "2A4D",
                propeties: .Notify,
                value: nil,
                permissions: .Readable)
        ]
        
        let mainService = BTPrimacyService(UUIDString: "C14D2C0A-401F-B7A9-841F-E2E93B80F631",
            primary: false,
            characteristics: characteristics)
    
        self.init(services: [mainService])
    }
    
    // MARK: Internal Methods

    func startAdevertisingWithCompletion(completion: BTPeripheralRoleBlock?) -> BTPeripheralManagerOperation {
        
        let startAdvertisingOperation = BTStartAdvertisingOperation(withPeripheralManager: peripheralManager,
            peripheralRolePerformer: self)
        
        startAdvertisingOperation.addObserver(DidFinishObserver { result in
            
            completion?(rolePerformer: self,
                result: BTOperationResult(operation: result.operation, errors: result.errors))
            })
        
        operationQueue.addOperation(startAdvertisingOperation)
        
        return startAdvertisingOperation
    }
}

// MARK: BTPeripheralManagerHandlerProtocol

extension BTPeripheralRolePerformer: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        DDLogVerbose("PeripheralManager: did update state = \(peripheral.state)")
        
        addServices()
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didAddService service: CBService, error: NSError?) {
        DDLogVerbose("PeripheralManager: did add service \(service) with error = \(error)")
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: BTPeripheralManagerAPIType, error: NSError?) {
        DDLogVerbose("PeripheralManager: did start advertising with error = \(error)")
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didReceiveReadRequest request: CBATTRequest) {
        DDLogVerbose("PeripheralManager: did receive read request = \(request)")
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didReceiveWriteRequests requests: [CBATTRequest]) {
        DDLogVerbose("PeripheralManager: did receive write requests = \(requests)")
    }
}

// MARK: Private methods

private extension BTPeripheralRolePerformer {
    func addServices() {
        let addServiceOperation = BTAddServicesOperation(withPeripheralManager: peripheralManager,
            peripheralRolePerformer: self,
            services: services)
        
        addServiceOperation.addObserver(DidFinishObserver { [weak weakSelf = self] result in
            
            if result.operation.finished && result.errors.isEmpty {
                weakSelf?.servicesAdded = true
            }
            
            })
        
        operationQueue.addOperation(addServiceOperation)
    }
}
