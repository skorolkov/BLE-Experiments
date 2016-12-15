//
//  BTPeripheralAPIProtocol+FindCharacretistics.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/1/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BTPeripheralAPIProtocol {
    public func characteristicWithUUIDString(UUIDString: String,
                                      properties: CBCharacteristicProperties) -> CBCharacteristic? {
        
        guard let services = self.services else {
            return nil
        }
        
        for service in services {
            if let characteristic = service.characteristicWithUUIDString(UUIDString, properties: properties) {
                return characteristic
            }
        }
        
        return nil
    }
}

extension CBService {
    func characteristicWithUUIDString(UUIDString: String,
                                      properties: CBCharacteristicProperties) -> CBCharacteristic? {
        
        guard let characteristics = self.characteristics else {
            return nil
        }
        
        guard let index = characteristics.indexOf({
            ($0.UUID.UUIDString == UUIDString) && $0.properties.contains(properties) }) else {
            return nil
        }
        
        return characteristics[index]
    }
}
