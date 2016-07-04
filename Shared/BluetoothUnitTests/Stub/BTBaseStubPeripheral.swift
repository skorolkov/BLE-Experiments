//
//  BTBaseStubPeripheral.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
@testable import BLE_Central_OSX

@objc class BTBaseStubPeripheral: NSObject, BTPeripheralAPIType {
        
    private(set) var identifier: NSUUID = NSUUID()
    
    private(set) var name: String?
    
    private(set) var state: CBPeripheralState = .Disconnected
    
    private(set) var services: [CBService]?
    
    // MARK: Private Properties
    
    private(set) var handlerContainer = BTHandlersContainer<BTPeripheralHandlerProtocol>()
    
    // MARK: Initializers
    
    private override init() {
        super.init()
    }
    
    init(identifier: NSUUID) {
        self.identifier = identifier
        super.init()
    }
    
    // MARK: Discover services and characterictics
    
    func discoverServices(serviceUUIDs: [CBUUID]?) {
        
    }
    
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, forService service: CBService) {
        
    }
    
    // MARK: Read value for characteristic
    
    func readValueForCharacteristic(characteristic: CBCharacteristic) {
        
    }
    
    // MARK: Write value for characteristic
    
    func writeValue(data: NSData, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        
    }
    
    // MARK: Subscribe on value update notifications for characteristic
    
    func setNotifyValue(enabled: Bool, forCharacteristic characteristic: CBCharacteristic) {
        
    }
    
    func coreBluetoothPeripheral() -> CBPeripheral {
        return BTStubCBPeriheral(name: "")
    }

    // MARK: Add handler
    
    func addHandler(handlerToAdd: BTPeripheralHandlerProtocol) {
        handlerContainer.addHandler(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTPeripheralHandlerProtocol) {
        handlerContainer.removeHandler(handlerToRemove)
    }
    
    func removeAllHandlers() {
        handlerContainer.removeAllHandlers()
    }
}

private class BTStubCBPeriheral: CBPeripheral {
    init(name: String) {}
}
