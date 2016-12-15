//
//  BTPrototypes.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/3/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth

public struct BTCharacteristicPrototype {
    public let UUID: CBUUID
    
    public init(UUID: CBUUID) {
        self.UUID = UUID
    }
}

public struct BTServicePrototype {
    public let UUID: CBUUID
    public let characteristicPrototypes: [BTCharacteristicPrototype]
    
    public init(UUID: CBUUID, characteristicPrototypes: [BTCharacteristicPrototype]) {
        self.UUID = UUID
        self.characteristicPrototypes = characteristicPrototypes
    }
}
