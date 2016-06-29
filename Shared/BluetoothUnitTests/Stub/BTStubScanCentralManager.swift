//
//  BTStubScanCentralManager.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
@testable import BLE_Central_OSX

class BTStubScanCentralManager: BTBaseStubCentralManager {
    
    // MARK: Scan for peripherals
    
    override func scanForPeripheralsWithServices(serviceUUIDs: [CBUUID]?, options: [String : AnyObject]?) {
        
       discoverFirstDeviceAfterDelay()
    }
    
    override func stopScan() {}
}

// MARK: Private Properties

private extension BTStubScanCentralManager {
    
    func discoverFirstDeviceAfterDelay() {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.3 * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.discoverFirstDevice()
            self.discoverSecondDeviceAfterDelay()
        }
    }
    
    func discoverSecondDeviceAfterDelay() {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.3 * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.discoverSecondDevice()
        }
    }
    
    func discoverFirstDevice() {
        
        let peripheral = BTBaseStubPeripheral(identifier: NSUUID(UUIDString: "954931C2-C010-4F7F-8244-6F406A684778")!)
        
        handlerContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) in
            handler.centralManager?(self,
                didDiscoverPeripheral: peripheral,
                advertisementData: [ : ],
                RSSI: 0)
        }
    }
    
    func discoverSecondDevice() {
        
        let peripheral = BTBaseStubPeripheral(identifier: NSUUID(UUIDString: "2B24F397-8F13-4A2C-909B-AEC7E660CC6D")!)
        
        handlerContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) in
            handler.centralManager?(self,
                didDiscoverPeripheral: peripheral,
                advertisementData: [ : ],
                RSSI: 0)
        }
    }
}