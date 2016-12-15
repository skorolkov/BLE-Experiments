//
//  BTCentralManagerInitializibleProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/11/16.
//
//

import CoreBluetooth

typealias BTCentralManagerInitializibleType = BTCentralManagerInitializibleProtocol

@objc protocol BTCentralManagerInitializibleProtocol: BTCentralManagerAPIProtocol {
    
    // MARK: Delegate
    
    weak var delegate: CBCentralManagerDelegate? { get set }
    
    // MARK: Initialization
    
    init(delegate: CBCentralManagerDelegate?, queue: dispatch_queue_t?, options: [String : AnyObject]?)
}

extension CBCentralManager: BTCentralManagerInitializibleProtocol {
    
    var managerState: BTManagerState {
        if #available(iOS 10, *) {
            return BTManagerState(state)
        } else {
            var workaroundState: CBCentralManagerState
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
    
    func connectPeripheralWithObject(peripheral: BTPeripheralAPIType, options: [String : AnyObject]?) {
        connectPeripheral(peripheral.coreBluetoothPeripheral(), options: options)
    }
    
    func cancelPeripheralConnectionWithObject(peripheral: BTPeripheralAPIType) {
        cancelPeripheralConnection(peripheral.coreBluetoothPeripheral())
    }
}
