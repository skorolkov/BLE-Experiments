//
//  CBPeripheralManagerState+StringConvertible.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheralManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Unknown:
            return "CBPeripheralManagerState.Unknown"
        case .Resetting:
            return "CBPeripheralManagerState.Resetting"
        case .Unsupported:
            return "CBPeripheralManagerState.Unsupported"
        case .Unauthorized:
            return "CBPeripheralManagerState.Unauthorized"
        case .PoweredOff:
            return "CBPeripheralManagerState.PoweredOff"
        case .PoweredOn:
            return "CBPeripheralManagerState.PoweredOn"
        }
    }
}

extension CBPeripheralManagerState: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
