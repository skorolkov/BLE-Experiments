//
//  CentralManagerLoggingHandler.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation
import CocoaLumberjack

class BTCentralManagerLoggingHandler: BTCentalManagerBlockHandler {
    
    override init() {
        super.init { (central: BTCentralManagerAPIType) -> Void in
            DDLogVerbose("CentralManager: did update state = \(central.state)")
        }
        
        self.willRestoreStateBlock = {
            (central: BTCentralManagerAPIType, willRestoreStateWithDict: [String : AnyObject]) in
            DDLogVerbose("CentralManager: will restore state = \(central.state)")
        }
        
        self.didConnectPeripheralBlock = {
            (central: BTCentralManagerAPIType, peripheral: BTPeripheralAPIType) in
            DDLogVerbose("CentralManager: did connect peripheral = \(peripheral)")
        }
        
        self.didDisconnectPeripheralBlock = {
            (central: BTCentralManagerAPIType, peripheral: BTPeripheralAPIType, error: NSError?) in
            DDLogVerbose("CentralManager: did disconnect peripheral = \(peripheral) with error = \(error)")
        }
        
        self.failToConnectToPeripheralBlock = {
            (central: BTCentralManagerAPIType, peripheral: BTPeripheralAPIType, error: NSError?) in
            DDLogVerbose("CentralManager: did fail to connect peripheral = \(peripheral) with error = \(error)")
        }
        
        self.didDiscoverPeripheralBlock = {
            (central: BTCentralManagerAPIType,
             discoveredPeripheral: BTPeripheralAPIType,
             advertisementData: [String : AnyObject],
             RSSI: NSNumber) in
            DDLogVerbose("CentralManager: did discover peripheral = \(discoveredPeripheral)")
        }
    }
}