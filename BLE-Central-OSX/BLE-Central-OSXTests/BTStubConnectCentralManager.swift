//
//  BTStubConnectCentralManager.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/10/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
@testable import BLE_Central_OSX

class BTStubSuccessConnectionCentralManager: BTBaseStubCentralManager {
    
    // MARK: Connecting to peripherals
    
    override func connectPeripheralWithObject(peripheral: BTPeripheralAPIType, options: [String : AnyObject]?) {
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.3 * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.handlerContainer.handlers.forEach({ (handler: BTCentralManagerHandlerProtocol) in
                
                handler.centralManager?(self, didConnectPeripheral: peripheral)
            })
        }
    }
}

class BTStubFailedConnectionCentralManager: BTBaseStubCentralManager {
    
    // MARK: Connecting to peripherals
    
    override func connectPeripheralWithObject(peripheral: BTPeripheralAPIType, options: [String : AnyObject]?) {
        
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(0.3 * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.handlerContainer.handlers.forEach({ (handler: BTCentralManagerHandlerProtocol) in
                
                handler.centralManager?(self,
                    didFailToConnectPeripheral: peripheral,
                    error: nil)
            })
        }
    }
}
