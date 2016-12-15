//
//  BTPeripheralManagerAPIProtocol.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol BTPeripheralManagerAPIProtocol: class {
    
    // MARK: State
    
    var managerState: BTManagerState { get }
    
    // MARK: Advertising state
    
    var isAdvertising: Bool { get }
    
    // MARK: Start/Stop Advertising
    
    func startAdvertising(advertisementData: [String : AnyObject]?)
    
    func stopAdvertising()
    
    // MARK: Manage Serives
    
    func addService(service: CBMutableService)
    
    func removeService(service: CBMutableService)
    
    func removeAllServices()
    
    // MARK: Responding To Requests
    
    func respondToRequest(request: CBATTRequest, withResult result: CBATTError)
    
    // MARK: Update Value for characteristic
    
    func updateValue(value: NSData, forCharacteristic characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool
    
}
