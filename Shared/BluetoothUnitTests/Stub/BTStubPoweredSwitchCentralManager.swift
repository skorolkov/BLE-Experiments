//
//  BTStubPoweredSwitchCentralManager.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

@testable import BLE_Central_OSX

class BTStubPoweredSwitchCentralManager: BTBaseStubCentralManager {
    
    override init() {
        super.init()
        self.managerState = .PoweredOff
    }
}
