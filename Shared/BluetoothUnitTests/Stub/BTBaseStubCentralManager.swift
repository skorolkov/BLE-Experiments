//
//  BTStubCentralManagers.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
@testable import BLE_Central_OSX

@objc class BTBaseStubCentralManager: NSObject, BTCentralManagerAPIWithHadlerProtocol {
    
    // MARK: Private Properties
    
    private(set) var handlerContainer = BTHandlersContainer<BTCentralManagerHandlerProtocol>()
    
    // MARK Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: State
    
    var managerState: BTManagerState = .Unknown {
        didSet {
            for handler in handlerContainer.handlers {
                handler.centralManagerDidUpdateState(self)
            }
        }
    }
    
    // MARK: Scan for peripherals
    
    func scanForPeripheralsWithServices(serviceUUIDs: [CBUUID]?, options: [String : AnyObject]?) {
        
    }
    
    func stopScan() {
        
    }
    
    // MARK: Retrieving peripherals
    
    func retrievePeripheralsWithIdentifiers(identifiers: [NSUUID]) -> [CBPeripheral] {
        return []
    }
    
    func retrieveConnectedPeripheralsWithServices(serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
        return []
    }
    
    // MARK: Connecting to peripherals
    
    func connectPeripheralWithObject(peripheral: BTPeripheralAPIType, options: [String : AnyObject]?) {
        
    }
    
    // MARK: Disconnecting from peripherals
    
    func cancelPeripheralConnectionWithObject(peripheral: BTPeripheralAPIType) {
        
    }
    
    // MARK: Add handler
    
    func addHandler(handlerToAdd: BTCentralManagerHandlerProtocol) {
        handlerContainer.addHandler(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTCentralManagerHandlerProtocol) {
        handlerContainer.removeHandler(handlerToRemove)
    }
}
