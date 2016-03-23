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

extension CBPeripheralManager: BTPeripheralManagerInitializibleProtocol {}