//
//  BTManagerState.swift
//  PowerDot-Athlete
//
//  Created by Sergey Korolkov on 14.10.16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc enum BTManagerState: Int {
    case Unknown
    case Resetting
    case Unsupported
    case Unauthorized
    case PoweredOff
    case PoweredOn
    
    #if os(OSX)
    //This init won't compile for osx
    //Availability macro won't help either
    #else
    @available(OSX, unavailable)
    @available(iOS 10, tvOS 10, *)
    init(_ state: CBManagerState) {
        switch state {
        case .Unknown: self = .Unknown
        case .Resetting: self = .Resetting
        case .Unsupported: self = .Unsupported
        case .Unauthorized: self = .Unauthorized
        case .PoweredOff: self = .PoweredOff
        case .PoweredOn: self = .PoweredOn
        }
    }
    #endif
    
    init(_ state: CBCentralManagerState) {
        switch state {
        case .Unknown: self = .Unknown
        case .Resetting: self = .Resetting
        case .Unsupported: self = .Unsupported
        case .Unauthorized: self = .Unauthorized
        case .PoweredOff: self = .PoweredOff
        case .PoweredOn: self = .PoweredOn
        }
    }
    
    init(_ state: CBPeripheralManagerState) {
        switch state {
        case .Unknown: self = .Unknown
        case .Resetting: self = .Resetting
        case .Unsupported: self = .Unsupported
        case .Unauthorized: self = .Unauthorized
        case .PoweredOff: self = .PoweredOff
        case .PoweredOn: self = .PoweredOn
        }
    }
}

extension BTManagerState: CustomStringConvertible {
    var description: String {
        switch self {
        case .Unknown:
            return "BTManagerState.Unknown"
        case .Resetting:
            return "BTManagerState.Resetting"
        case .Unsupported:
            return "BTManagerState.Unsupported"
        case .Unauthorized:
            return "BTManagerState.Unauthorized"
        case .PoweredOff:
            return "BTManagerState.PoweredOff"
        case .PoweredOn:
            return "BTManagerState.PoweredOn"
        }
    }
}

extension BTManagerState: CustomDebugStringConvertible {
    var debugDescription: String {
        return description
    }
}
