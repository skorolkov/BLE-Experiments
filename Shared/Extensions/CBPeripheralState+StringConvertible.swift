//
//  CBPeripheralState+StringConvertible.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/8/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBPeripheralState: CustomStringConvertible {

    public var description: String {
        switch self {
        case .Disconnected:
            return "CBPeripheralState.Disconnected"
        case .Connecting:
            return "CBPeripheralState.Connecting"
        case .Connected:
            return "CBPeripheralState.Connected"
        default:
            return ""
        }
    }
}

extension CBPeripheralState: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}