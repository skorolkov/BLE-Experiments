//
//  BTPeripheralManagerHandlerProtocol.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth

@objc protocol BTPeripheralManagerHandlerProtocol: NSObjectProtocol {
    
    // MARK: Monitoring Peripheral's State Changes
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType)
    
    // MARK: Peripheral Manager Advertising Added
    
    optional func peripheralManagerDidStartAdvertising(peripheral: BTPeripheralManagerAPIType,
        error: NSError?)
    
    // MARK: Peripheral Manager Service Added
    
    optional func peripheralManager(peripheral: BTPeripheralManagerAPIType,
        didAddService service: CBService,
        error: NSError?)
    
    // MARK: Receiving Read/Write Requests
    
    optional func peripheralManager(peripheral: BTPeripheralManagerAPIType,
        didReceiveReadRequest request: CBATTRequest)
    
    optional func peripheralManager(peripheral: BTPeripheralManagerAPIType,
        didReceiveWriteRequests requests: [CBATTRequest])
}
