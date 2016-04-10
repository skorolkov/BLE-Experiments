//
//  BTPeripheralLoggingHandler.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation
import CoreBluetooth
import CocoaLumberjack

class BTPeripheralLoggingHandler: BTPeripheralBlockHandler {
    
    override init() {
        super.init()
        
        self.didUpdateNameBlock = { (peripheral: BTPeripheralAPIType) in
            DDLogVerbose("Peripheral: did update peripheral name = \(peripheral)")
        }
        
        self.didDiscoverServicesBlock = { (peripheral: BTPeripheralAPIType, error: NSError?) in
            DDLogVerbose("Peripheral: did discover services with error = \(error)")
        }
        
        self.didDiscoverCharacteristicsBlock = {
            (peripheral: BTPeripheralAPIType, service: CBService, error: NSError?) in
            DDLogVerbose("Peripheral: did discover characteristic for service = \(service) with error = \(error)")
        }
        
        self.didUpdateValueForCharacteristicBlock = {
            (peripheral: BTPeripheralAPIType, characteristic: CBCharacteristic, error: NSError?) in
            DDLogVerbose("Peripheral: did update value for characteristic = \(characteristic) with error = \(error)")
        }
        
        self.didWriteValueForCharacteristicBlock = {
            (peripheral: BTPeripheralAPIType, characteristic: CBCharacteristic, error: NSError?) in
            DDLogVerbose("Peripheral: did write value for characteristic = \(characteristic) with error = \(error)")
        }
        
        self.didUpdateNotificationStateForCharacteristicBlock = {
            (peripheral: BTPeripheralAPIType, characteristic: CBCharacteristic, error: NSError?) in
            DDLogVerbose("Peripheral: did update notifications state for characteristic = \(characteristic) \n" +
                "with error = \(error)")
        }
    }
}