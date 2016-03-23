//
//  BTStartAdvertisingOperation.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

class BTStartAdvertisingOperation: BTPeripheralManagerOperation {
    
    var advertisingData: [String : AnyObject]?
    
    override init(withPeripheralManager peripheralManager: BTPeripheralManagerProxy) {
        super.init(withPeripheralManager: peripheralManager)
        
        addCondition(BTBluetoothPoweredOnCondition(withPeripheralManager: peripheralManager))
    }
    
    override func execute() {
        peripheralManager?.addHandler(self)
        
        peripheralManager?.startAdvertising(advertisingData)
    }
}

extension BTStartAdvertisingOperation: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        // nothing to do here
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: BTPeripheralManagerAPIType, error: NSError?) {
        
        peripheralManager?.removeHandler(self)
        
        if let error = error {
            finish(error)
        }
        else {
            finish()
        }
    }
}
