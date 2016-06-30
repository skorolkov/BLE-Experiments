//
//  BTPeripheral.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BTPeripheralState {
    case Unknown
    case Disconnected(error: NSError?)
    case Scanned(advertisementData: [String : AnyObject], RSSI: NSNumber)
    case Connected
    case CharacteristicDiscovered
}

extension BTPeripheralState: Equatable {}

func ==(left: BTPeripheralState, right: BTPeripheralState) -> Bool {
    switch (left, right) {
    case (.Unknown, .Unknown),
         (.Connected, .Connected),
         (.CharacteristicDiscovered, .CharacteristicDiscovered):
        return true
    case (.Disconnected(let l_error), .Disconnected(let r_error)):
        return (l_error?.domain == r_error?.domain && l_error?.code == r_error?.code)
    case (.Scanned(_, let l_RSSI), .Scanned(_, let r_RSSI)):
        return l_RSSI == r_RSSI
    default:
        return false
    }
}

struct BTPeripheral {
    let identifierString: String
    let name: String?
    let state: BTPeripheralState
    
    let characteristics: [BTCharacteristic]
    
    init(identifierString: String,
         name: String?,
         state: BTPeripheralState,
         characteristics: [BTCharacteristic] = []) {
        self.identifierString = identifierString
        self.name = name
        self.state = state
        self.characteristics = characteristics
    }
    
    init(peripheral: BTPeripheralAPIType, state: BTPeripheralState) {
        self.identifierString = peripheral.identifier.UUIDString
        self.name = peripheral.name
        self.state = state
        self.characteristics = []
    }
}

extension BTPeripheral: Equatable {}

func ==(left: BTPeripheral, right: BTPeripheral) -> Bool {
    return (left.identifierString == right.identifierString &&
        left.name == right.name &&
        left.state == right.state)
}

extension BTPeripheral {
    static func createWithDisconnectedPeripheral(peripheral: BTPeripheralAPIType, error: NSError?) -> BTPeripheral {
        return BTPeripheral(peripheral: peripheral, state: .Disconnected(error: error))
    }
    
    static func createWithScanResult(discoveryResult: BTPeripheralScanResult) -> BTPeripheral {
        return BTPeripheral(
            peripheral: discoveryResult.peripheral,
            state: .Scanned(advertisementData: discoveryResult.advertisementData, RSSI: discoveryResult.RSSI))
    }
    
    static func createWithConnectedPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheral {
        return BTPeripheral(peripheral: peripheral, state: .Connected)
    }
    
    static func createWithDiscoveredPeripheral(peripheral: BTPeripheralAPIType) -> BTPeripheral {
        return BTPeripheral(peripheral: peripheral, state: .CharacteristicDiscovered)
    }
    
    static func createWithPeripheral(
        peripheral: BTPeripheralAPIType,
        state: BTPeripheralState,
        characteristic: CBCharacteristic) -> BTPeripheral {
        
        let modelCharacteristic = BTCharacteristic(coreBluetoothCharacteristic: characteristic)
        return BTPeripheral(identifierString: peripheral.identifier.UUIDString,
                            name: peripheral.name,
                            state: state,
                            characteristics: [modelCharacteristic])
    }
}
