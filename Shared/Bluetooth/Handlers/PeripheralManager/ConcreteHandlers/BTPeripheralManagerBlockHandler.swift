//
//  BTPeripheralManagerBlockHandler.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc class BTPeripheralManagerBlockHandler: BTCustomQueueHandler {
    
    // MARK: Typenames
    
    typealias BTPeripheralManagerBlock = (peripheral: BTPeripheralManagerAPIType) -> Void
    typealias BTPeripheralManagerServiceBlock = (peripheral: BTPeripheralManagerAPIType, addedService: CBService,
        error: NSError?) -> Void
    typealias BTPeripheralManagerAdvertisingBlock = (peripheral: BTPeripheralManagerAPIType, error: NSError?) -> Void
    typealias BTPeripheralManagerReadBlock = (peripheral: BTPeripheralManagerAPIType, receivedReadRequest: CBATTRequest) -> Void
    typealias BTPeripheralManagerWriteBlock = (peripheral: BTPeripheralManagerAPIType, receivedWriteRequests: [CBATTRequest]) -> Void

    // MARK: Internal Properties
    
    var didUpdateStateBlock: BTPeripheralManagerBlock
    var didAddServiceBlock: BTPeripheralManagerServiceBlock?
    var didStartAdvertisingBlock: BTPeripheralManagerAdvertisingBlock?
    var didReceiveReadRequestBlock: BTPeripheralManagerReadBlock?
    var didReceiveWriteRequestsBlock : BTPeripheralManagerWriteBlock?
    
    // MARK: Initializers
    
    init(withDidUpdateStateBlock didUpdateStateBlock: BTPeripheralManagerBlock) {
        self.didUpdateStateBlock = didUpdateStateBlock
        super.init()
    }
    
    init(withDidUpdateStateBlock didUpdateStateBlock: BTPeripheralManagerBlock,
                                 handlerQueue: dispatch_queue_t) {
        self.didUpdateStateBlock = didUpdateStateBlock
        super.init(withHandlerQueue: handlerQueue)
    }
    
    override init(withHandlerQueue queue: dispatch_queue_t) {
        self.didUpdateStateBlock = { _ in }
        super.init(withHandlerQueue: queue)
    }
    
    override init() {
        self.didUpdateStateBlock = { _ in }
        super.init()
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTPeripheralManagerBlockHandler: BTPeripheralManagerHandlerProtocol {
    // MARK: Monitoring Peripheral's State Changes
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        dispatch_async(queue) { [unowned self] () -> Void in
            self.didUpdateStateBlock(peripheral: peripheral)
        }
    }
    
    // MARK: Peripheral Manager Advertising Added
    
    func peripheralManagerDidStartAdvertising(peripheral: BTPeripheralManagerAPIType,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didStartAdvertisingBlock?(peripheral: peripheral, error: error)
            }
    }
    
    // MARK: Peripheral Manager Service Added
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType,
        didAddService service: CBService,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didAddServiceBlock?(peripheral: peripheral,
                    addedService: service,
                    error: error)
            }
    }
    
    // MARK: Receiving Read/Write Requests
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType,
        didReceiveReadRequest request: CBATTRequest) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didReceiveReadRequestBlock?(peripheral: peripheral, receivedReadRequest: request)
            }
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType,
        didReceiveWriteRequests requests: [CBATTRequest]) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didReceiveWriteRequestsBlock?(peripheral: peripheral, receivedWriteRequests: requests)
            }
    }
}
