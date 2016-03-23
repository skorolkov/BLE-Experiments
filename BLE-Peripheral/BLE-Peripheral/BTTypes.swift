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
    let propeties: CBCharacteristicProperties
    let initialValue: NSData?
    let permissions: CBAttributePermissions
    
    init(UUIDString: String,
        propeties: CBCharacteristicProperties,
        initialValue: NSData?,
        permissions: CBAttributePermissions) {
            self.UUID = CBUUID(string: UUIDString)
            self.propeties = propeties
            self.initialValue = initialValue
            self.permissions = permissions
    }
}

struct BTService {
    let UUID: CBUUID
    let primary: Bool
    let characteristics: [BTCharacteristic]
    
    init(UUIDString: String, primary: Bool, characteristics: [BTCharacteristic]) {
        self.UUID = CBUUID(string: UUIDString)
        self.primary = primary
        self.characteristics = characteristics
    }
}

extension BTCharacteristic {
    func coreBluetoothCharacteristic() -> CBMutableCharacteristic {
        return CBMutableCharacteristic(type: UUID,
            properties: propeties,
            value: initialValue,
            permissions: permissions)
    }
}

extension BTService {
    func coreBluetoothService() -> CBMutableService {
        let service = CBMutableService(type: UUID, primary: primary)
        service.characteristics = characteristics.map { $0.coreBluetoothCharacteristic() }
        return service
    }
}
