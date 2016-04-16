//
//  BTPeripheralManagerLoggingHandler.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/10/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import CocoaLumberjack

class BTPeripheralManagerLoggingHandler: BTPeripheralManagerBlockHandler {
    
    override init() {
        super.init()
        
        self.didUpdateStateBlock = { (peripheral: BTPeripheralManagerAPIType) in
            DDLogVerbose("PeripheralManager: did update state = \(peripheral.state)")
        }
        
        self.didAddServiceBlock = {
            (peripheral: BTPeripheralManagerAPIType, addedService: CBService, error: NSError?) in
            DDLogVerbose("PeripheralManager: did add service \(addedService) with error = \(error)")
        }
        
        self.didStartAdvertisingBlock = {
            (peripheral: BTPeripheralManagerAPIType, error: NSError?) in
            DDLogVerbose("PeripheralManager: did start advertising with error = \(error)")
        }
        
        self.didReceiveReadRequestBlock  = {
            (peripheral: BTPeripheralManagerAPIType, receivedReadRequest: CBATTRequest) in
            DDLogVerbose("PeripheralManager: did receive read request = \(receivedReadRequest)")
        }
        
        self.didReceiveWriteRequestsBlock = {
            (peripheral: BTPeripheralManagerAPIType, receivedWriteRequests: [CBATTRequest]) in
            DDLogVerbose("PeripheralManager: did receive write requests = \(receivedWriteRequests)")
        }
    }
}