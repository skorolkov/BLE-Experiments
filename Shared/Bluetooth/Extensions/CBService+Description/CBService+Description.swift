//
//  CBService+Description.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBService {
    override public var description: String {
        return "<\(NSStringFromClass(self.dynamicType)): " +
            "UUID=\(UUID.UUIDString), isPrimary=\(isPrimary), characteristics=\(characteristics)>"
    }
    
    override public var debugDescription: String {
        return description
    }
}