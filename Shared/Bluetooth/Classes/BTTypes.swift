//
//  BTTypes.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth

struct BTCharacteristic {
    let UUID: CBUUID
    let properties: CBCharacteristicProperties
    let isNotifying: Bool
    let value: NSData?
    
    init(UUIDString: String,
         properties: CBCharacteristicProperties,
         isNotifying: Bool,
         value: NSData?) {
        self.UUID = CBUUID(string: UUIDString)
        self.properties = properties
        self.isNotifying = isNotifying
        self.value = value?.copy() as? NSData
    }
    
    init(characteristic: BTCharacteristic) {
        self.UUID = characteristic.UUID.copy() as! CBUUID
        self.properties = characteristic.properties
        self.isNotifying = characteristic.isNotifying
        self.value = characteristic.value?.copy() as? NSData
    }
    
    init(coreBluetoothCharacteristic: CBCharacteristic) {
        self.init(UUIDString: coreBluetoothCharacteristic.UUID.UUIDString,
                  properties: coreBluetoothCharacteristic.properties,
                  isNotifying: coreBluetoothCharacteristic.isNotifying,
                  value: coreBluetoothCharacteristic.value)
    }
}

extension BTCharacteristic: Equatable {}

func ==(left: BTCharacteristic, right: BTCharacteristic) -> Bool {
    return (left.UUID == right.UUID &&
        left.properties == right.properties &&
        left.value == right.value)
}

struct BTService {
    let UUID: CBUUID
    let characteristics: [BTCharacteristic]
    
    init(UUIDString: String, characteristics: [BTCharacteristic]) {
        self.UUID = CBUUID(string: UUIDString)
        self.characteristics = characteristics
    }
    
    init(service: BTService) {
        self.UUID = service.UUID
        self.characteristics = service.characteristics
    }
    
    init(coreBluetoothService: CBService) {
        let characteristics =
            coreBluetoothService.characteristics?.map { BTCharacteristic(coreBluetoothCharacteristic:$0) } ?? []
        
        self.init(UUIDString: coreBluetoothService.UUID.UUIDString,
                  characteristics: characteristics)
    }
}

class BTPermissionsCharacteristic {
    let UUID: CBUUID
    let properties: CBCharacteristicProperties
    let permissions: CBAttributePermissions
    let value: NSData?

    init(UUIDString: String,
         properties: CBCharacteristicProperties,
         permissions: CBAttributePermissions,
         value: NSData?) {
        self.UUID = CBUUID(string: UUIDString)
        self.properties = properties
        self.permissions = permissions
        self.value = value?.copy() as? NSData
    }
}

func ==(left: BTPermissionsCharacteristic, right: BTPermissionsCharacteristic) -> Bool {
    return (left.UUID == right.UUID &&
        left.properties == right.properties &&
        left.permissions == right.permissions &&
        left.value == right.value)
}

struct BTPrimacyService {
    let UUID: CBUUID
    let primary: Bool
    let permissionCharacteristics: [BTPermissionsCharacteristic]
    
    init(UUIDString: String, primary: Bool, permissionCharacteristics: [BTPermissionsCharacteristic]) {
        self.UUID = CBUUID(string: UUIDString)
        self.primary = primary
        self.permissionCharacteristics = permissionCharacteristics
    }
}

extension BTPermissionsCharacteristic {
    func coreBluetoothMutableCharacteristic() -> CBMutableCharacteristic {
        return CBMutableCharacteristic(type: UUID,
            properties: properties,
            value: value,
            permissions: permissions)
    }
}

extension BTPrimacyService {
    func coreBluetoothMUtableService() -> CBMutableService {
        let service = CBMutableService(type: UUID, primary: primary)
        service.characteristics = permissionCharacteristics.map { $0.coreBluetoothMutableCharacteristic() }
        return service
    }
}
