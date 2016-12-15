//
//  BTPeripheralManagerInitializableProtocol.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth

typealias BTPeripheralManagerInitializibleType = BTPeripheralManagerInitializibleProtocol

@objc protocol BTPeripheralManagerInitializibleProtocol: BTPeripheralManagerAPIProtocol {
    
    // MARK: Delegate
    
    weak var delegate: CBPeripheralManagerDelegate? { get set }
    
    // MARK: Initialization
    
    init(delegate: CBPeripheralManagerDelegate?, queue: dispatch_queue_t?, options: [String : AnyObject]?)
}

extension CBPeripheralManager: BTPeripheralManagerInitializibleProtocol {
    var managerState: BTManagerState {
        if #available(iOS 10, *) {
            return BTManagerState(state)
        } else {
            var workaroundState: CBPeripheralManagerState
            switch state {
            case .Unknown: workaroundState = .Unknown
            case .Resetting: workaroundState = .Resetting
            case .Unsupported: workaroundState = .Unsupported
            case .Unauthorized: workaroundState = .Unauthorized
            case .PoweredOff: workaroundState = .PoweredOff
            case .PoweredOn: workaroundState = .PoweredOn
            }
            return BTManagerState(workaroundState)
        }
    }
}
