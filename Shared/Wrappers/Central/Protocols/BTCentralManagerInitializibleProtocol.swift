//
//  BTCentralManagerInitializibleProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/11/16.
//
//

import CoreBluetooth

@objc protocol BTCentralManagerInitializibleProtocol: BTCentralManagerAPIProtocol {
    
    // MARK: Delegate
    
    weak var delegate: CBCentralManagerDelegate? { get set }
    
    // MARK: Initialization
    
    init(delegate: CBCentralManagerDelegate?, queue: dispatch_queue_t?, options: [String : AnyObject]?)
}

extension CBCentralManager: BTCentralManagerInitializibleProtocol {}