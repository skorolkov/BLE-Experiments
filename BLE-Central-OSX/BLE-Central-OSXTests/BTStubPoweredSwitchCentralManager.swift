//
//  BTStubPoweredSwitchCentralManager.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

class BTStubPoweredSwitchCentralManager: BTBaseStubCentralManager {
    
    override init() {
        super.init()
        state = .PoweredOff
    }
}
