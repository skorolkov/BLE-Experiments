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

class BTService {
    let UUID: CBUUID
    let characteristics: [BTCharacteristic]
    
    init(UUIDString: String, characteristics: [BTCharacteristic]) {
        self.UUID = CBUUID(string: UUIDString)
        self.characteristics = characteristics
    }
}

class BTPrimacyService: BTService {
    let primary: Bool

    init(UUIDString: String, primary: Bool, characteristics: [BTCharacteristic]) {
        self.primary = primary
        super.init(UUIDString: UUIDString, characteristics: characteristics)
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

extension BTPrimacyService {
    func coreBluetoothService() -> CBMutableService {
        let service = CBMutableService(type: UUID, primary: primary)
        service.characteristics = characteristics.map { $0.coreBluetoothCharacteristic() }
        return service
    }
}
