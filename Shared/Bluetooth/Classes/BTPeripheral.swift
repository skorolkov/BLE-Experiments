//
//  BTPeripheral.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BTPeripheralState: Int {
    case Disconnected
    case Discovered
    case Connected
    case CharacteristicDiscovered
}

struct BTPeripheral {
    let identifierString: String
    let name: String?
    let state: BTPeripheralState
    
    init(identifierString: String, name: String?, state: BTPeripheralState) {
        self.identifierString = identifierString
        self.name = name
        self.state = state
    }
}
