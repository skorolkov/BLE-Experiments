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
    let propeties: CBCharacteristicProperties
    let value: NSData?
    
    init(UUIDString: String,
         propeties: CBCharacteristicProperties,
         value: NSData?) {
        self.UUID = CBUUID(string: UUIDString)
        self.propeties = propeties
        self.value = value
    }
    
    init(characteristic: BTCharacteristic) {
        self.UUID = characteristic.UUID
        self.propeties = characteristic.propeties
        self.value = characteristic.value
    }
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
         propeties: CBCharacteristicProperties,
         value: NSData?,
         permissions: CBAttributePermissions) {
        self.permissions = permissions
        super.init(UUIDString: UUIDString,
                   propeties: propeties,
                   value: value)
    }
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
            properties: propeties,
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
                  propeties: coreBluetoothCharacteristic.properties,
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
