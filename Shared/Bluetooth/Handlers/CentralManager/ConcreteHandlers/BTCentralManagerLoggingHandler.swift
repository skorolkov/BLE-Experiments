//
//  CentralManagerLoggingHandler.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation
import XCGLogger

class BTCentralManagerLoggingHandler: BTCentalManagerBlockHandler {
    
    //MARK: Private Properties
    private let logger: XCGLogger
    
    init(logger: XCGLogger) {
        self.logger = logger
        super.init { (central: BTCentralManagerAPIType) -> Void in
            logger.verbose("CentralManager: did update state = \(central.state)")
        }
        
        self.willRestoreStateBlock = {
            (central: BTCentralManagerAPIType, willRestoreStateWithDict: [String : AnyObject]) in
            logger.verbose("CentralManager: will restore state = \(central.state)")
        }
        
        self.didConnectPeripheralBlock = {
            (central: BTCentralManagerAPIType, peripheral: BTPeripheralAPIType) in
            logger.verbose("CentralManager: did connect peripheral = \(peripheral)")
        }
        
        self.didDisconnectPeripheralBlock = {
            (central: BTCentralManagerAPIType, peripheral: BTPeripheralAPIType, error: NSError?) in
            logger.verbose("CentralManager: did disconnect peripheral = \(peripheral) with error = \(error)")
        }
        
        self.failToConnectToPeripheralBlock = {
            (central: BTCentralManagerAPIType, peripheral: BTPeripheralAPIType, error: NSError?) in
            logger.verbose("CentralManager: did fail to connect peripheral = \(peripheral) with error = \(error)")
        }
        
        self.didDiscoverPeripheralBlock = {
            (central: BTCentralManagerAPIType,
             discoveredPeripheral: BTPeripheralAPIType,
             advertisementData: [String : AnyObject],
             RSSI: NSNumber) in
            logger.verbose("CentralManager: did discover peripheral = \(discoveredPeripheral)")
        }
    }
}