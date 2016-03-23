//
//  CentralManagerHandlerProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/7/16.
//
//

import CoreBluetooth

/**
 * BTCentralManagerHandlerProtocol inherits from NSObjectProtocol
 * because we need isEqual method
 */

@objc protocol BTCentralManagerHandlerProtocol: NSObjectProtocol {
    
    // MARK: Monitoring Changes to the Central Manager’s State
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType)
    
    optional func centralManager(central: BTCentralManagerAPIType,
        willRestoreState dict: [String : AnyObject])
    
    // MARK: Monitoring Connections with Peripherals
    
    optional func centralManager(central: BTCentralManagerAPIType,
        didConnectPeripheral peripheral: BTPeripheralAPIType)
    
    optional func centralManager(central: BTCentralManagerAPIType,
        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
        error: NSError?)
    
    optional func centralManager(central: BTCentralManagerAPIType,
        didFailToConnectPeripheral peripheral: BTPeripheralAPIType,
        error: NSError?)
    
    // MARK: Discovering and Retrieving Peripherals
    
    optional func centralManager(central: BTCentralManagerAPIType,
        didDiscoverPeripheral peripheral: BTPeripheralAPIType,
        advertisementData: [String : AnyObject],
        RSSI: NSNumber)
}
