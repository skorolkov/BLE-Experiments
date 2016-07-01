//
//  CBCentralManagerState+StringConvertible.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/8/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBCentralManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Unknown:
            return "CBCentralManagerState.Unknown"
        case .Resetting:
            return "CBCentralManagerState.Resetting"
        case .Unsupported:
            return "CBCentralManagerState.Unsupported"
        case .Unauthorized:
            return "CBCentralManagerState.Unauthorized"
        case .PoweredOff:
            return "CBCentralManagerState.PoweredOff"
        case .PoweredOn:
            return "CBCentralManagerState.PoweredOn"
        }
    }
}

extension CBCentralManagerState: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
