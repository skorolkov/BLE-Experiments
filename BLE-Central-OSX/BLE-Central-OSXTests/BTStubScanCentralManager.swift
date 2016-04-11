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
        
       discoverNewDeviceAfterDelay()
    }
    
    override func stopScan() {}
}

// MARK: Private Properties

private extension BTStubScanCentralManager {
    
    func discoverNewDeviceAfterDelay() {
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.3 * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.discoverNewDevice()
            self.discoverNewDeviceAfterDelay()
        }
    }
    
    func discoverNewDevice() {
        
        let peripheral = BTBaseStubPeripheral()
        
        handlerContainer.handlers.forEach { (handler: BTCentralManagerHandlerProtocol) in
            handler.centralManager?(self,
                didDiscoverPeripheral: peripheral,
                advertisementData: [ : ],
                RSSI: 0)
        }
    }
}