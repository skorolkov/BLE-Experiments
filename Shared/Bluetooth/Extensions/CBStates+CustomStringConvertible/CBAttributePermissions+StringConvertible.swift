//
//  CBAttributePermissions+StringConvertible.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/2/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBAttributePermissions: CustomStringConvertible {
    
    public var description: String {
        
        var propertyNames: [String] = []
        
        if self.contains(.Readable) {
            propertyNames.append(".Readable")
        }
        if self.contains(.Writeable) {
            propertyNames.append(".Writeable")
        }
        if self.contains(.ReadEncryptionRequired) {
            propertyNames.append(".ReadEncryptionRequired")
        }
        if self.contains(.WriteEncryptionRequired) {
            propertyNames.append(".WriteEncryptionRequired")
        }
        
        return "[\(propertyNames.joinWithSeparator(","))]"
    }
}

extension CBAttributePermissions: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}