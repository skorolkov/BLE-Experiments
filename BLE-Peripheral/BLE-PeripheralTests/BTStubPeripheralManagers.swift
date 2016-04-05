//
//  BTStubPeripheralManagers.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
@testable import BLE_Peripheral

@objc class BTBaseStubPeripheralManager: NSObject, BTPeripheralManagerAPIWithHadlerProtocol {
    
    // MARK: Private Properties
    
    private var handlerContainer = BTHandlersContainer<BTPeripheralManagerHandlerProtocol>()
    
    // MARK Initializers

    override init() {
        super.init()
    }
    
    // MARK: State
    
    var state: CBPeripheralManagerState = .Unknown
    
    // MARK: Advertising state
    
    private(set) var isAdvertising: Bool = false
    
    // MARK: Start/Stop Advertising
    
    func startAdvertising(advertisementData: [String : AnyObject]?) {
        isAdvertising = true
    }
    
    func stopAdvertising() {
        isAdvertising = false
    }
    
    // MARK: Manage Serives
    
    func addService(service: CBMutableService) {
        
    }
    
    func removeService(service: CBMutableService) {
        
    }
    
    func removeAllServices() {
        
    }
    
    // MARK: Responding To Requests
    
    func respondToRequest(request: CBATTRequest, withResult result: CBATTError) {
        
    }
    
    // MARK: Update Value for characteristic
    
    func updateValue(value: NSData, forCharacteristic characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
        return true
    }
    
    // MARK: Add Handler
    
    func addHandler(handlerToAdd: BTPeripheralManagerHandlerProtocol) {
        handlerContainer.addHandler(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTPeripheralManagerHandlerProtocol) {
        handlerContainer.removeHandler(handlerToRemove)
    }
}

class BTStubPoweredOffPeripheralManagers: BTBaseStubPeripheralManager {
    
    override init() {
        super.init()
        state = .PoweredOff
    }
}

