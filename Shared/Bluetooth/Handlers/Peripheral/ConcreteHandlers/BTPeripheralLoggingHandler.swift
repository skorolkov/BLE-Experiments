//
//  BTPeripheralLoggingHandler.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation
import CoreBluetooth
import XCGLogger

class BTPeripheralLoggingHandler: BTPeripheralBlockHandler {
    
    //MARK: Private Properties
    private let logger: XCGLogger
    
    init(logger: XCGLogger) {
        self.logger = logger
        super.init()
        
        self.didUpdateNameBlock = { (peripheral: BTPeripheralAPIType) in
            logger.verbose("Peripheral: did update peripheral name = \(peripheral)")
        }
        
        self.didDiscoverServicesBlock = { (peripheral: BTPeripheralAPIType, error: NSError?) in
            logger.verbose("Peripheral: did discover services with error = \(error)")
        }
        
        self.didDiscoverCharacteristicsBlock = {
            (peripheral: BTPeripheralAPIType, service: CBService, error: NSError?) in
            logger.verbose("Peripheral: did discover characteristic for service = \(service) with error = \(error)")
        }
        
        self.didUpdateValueForCharacteristicBlock = {
            (peripheral: BTPeripheralAPIType, characteristic: CBCharacteristic, error: NSError?) in
            logger.verbose("Peripheral: did update value for characteristic = \(characteristic) with error = \(error)")
        }
        
        self.didWriteValueForCharacteristicBlock = {
            (peripheral: BTPeripheralAPIType, characteristic: CBCharacteristic, error: NSError?) in
            logger.verbose("Peripheral: did write value for characteristic = \(characteristic) with error = \(error)")
        }
        
        self.didUpdateNotificationStateForCharacteristicBlock = {
            (peripheral: BTPeripheralAPIType, characteristic: CBCharacteristic, error: NSError?) in
            logger.verbose("Peripheral: did update notifications state for characteristic = \(characteristic) \n" +
                "with error = \(error)")
        }
    }
}