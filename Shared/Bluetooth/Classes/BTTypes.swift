//
//  BTTypes.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth

class BTCharacteristic {
    let UUID: CBUUID
    let properties: CBCharacteristicProperties
    let value: NSData?
    
    init(UUIDString: String,
         properties: CBCharacteristicProperties,
         value: NSData?) {
        self.UUID = CBUUID(string: UUIDString)
        self.properties = properties
        self.value = value
    }
    
    init(characteristic: BTCharacteristic) {
        self.UUID = characteristic.UUID
        self.properties = characteristic.properties
        self.value = characteristic.value
    }
}

func ==(left: BTCharacteristic, right: BTCharacteristic) -> Bool {
    return (left.UUID == right.UUID &&
        left.properties == right.properties)
}

class BTService {
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
}

class BTPermissionsCharacteristic: BTCharacteristic {
    let permissions: CBAttributePermissions

    init(UUIDString: String,
         properties: CBCharacteristicProperties,
         value: NSData?,
         permissions: CBAttributePermissions) {
        self.permissions = permissions
        super.init(UUIDString: UUIDString,
                   properties: properties,
                   value: value)
    }
}

func ==(left: BTPermissionsCharacteristic, right: BTPermissionsCharacteristic) -> Bool {
    return (left.UUID == right.UUID &&
        left.properties == right.properties &&
        left.permissions == right.permissions)
}

class BTPrimacyService: BTService {
    let primary: Bool

    var permissionCharacteristics: [BTPermissionsCharacteristic]? {
        return characteristics as? [BTPermissionsCharacteristic]
    }
    
    init(UUIDString: String, primary: Bool, characteristics: [BTCharacteristic]) {
        self.primary = primary
        super.init(UUIDString: UUIDString, characteristics: characteristics)
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
        service.characteristics = permissionCharacteristics?.map { $0.coreBluetoothMutableCharacteristic() }
        return service
    }
}

extension BTCharacteristic {
    convenience init(coreBluetoothCharacteristic: CBCharacteristic) {
        self.init(UUIDString: coreBluetoothCharacteristic.UUID.UUIDString,
                  properties: coreBluetoothCharacteristic.properties,
                  value: coreBluetoothCharacteristic.value)
    }
}

extension BTService {
    convenience init(coreBluetoothService: CBService) {
        let characteristics =
            coreBluetoothService.characteristics?.map { BTCharacteristic(coreBluetoothCharacteristic:$0) } ?? []
        
        self.init(UUIDString: coreBluetoothService.UUID.UUIDString,
                  characteristics: characteristics)
    }
}
