//
//  CBUUID+Description.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBUUID {
    override public var description: String {
        return "<\(NSStringFromClass(self.dynamicType)): \(UUIDString)>"
    }
    
    override public var debugDescription: String {
        return description
    }
}