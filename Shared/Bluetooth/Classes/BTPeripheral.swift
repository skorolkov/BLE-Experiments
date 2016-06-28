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
    case Scanned
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
    
    init(peripheral: BTPeripheralAPIType, state: BTPeripheralState) {
        self.identifierString = peripheral.identifier.UUIDString
        self.name = peripheral.name
        self.state = state
    }
}

extension BTPeripheral: Equatable {}

func ==(left: BTPeripheral, right: BTPeripheral) -> Bool {
    return (left.identifierString == right.identifierString &&
        left.name == right.name &&
        left.state == right.state)
}
