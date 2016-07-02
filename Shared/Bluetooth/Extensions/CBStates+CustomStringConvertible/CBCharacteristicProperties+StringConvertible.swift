//
//  CBCharacteristicProperties+StringConvertible.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/2/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBCharacteristicProperties: CustomStringConvertible {
    
    public var description: String {
        
        var propertyNames: [String] = []
        
        if self.contains(.Broadcast) {
            propertyNames.append(".Broadcast")
        }
        if self.contains(.Read) {
            propertyNames.append(".Read")
        }
        if self.contains(.WriteWithoutResponse) {
            propertyNames.append(".WriteWithoutResponse")
        }
        if self.contains(.Write) {
            propertyNames.append(".Write")
        }
        if self.contains(.Notify) {
            propertyNames.append(".Notify")
        }
        if self.contains(.Indicate) {
            propertyNames.append(".Indicate")
        }
        if self.contains(.AuthenticatedSignedWrites) {
            propertyNames.append(".AuthenticatedSignedWrites")
        }
        if self.contains(.ExtendedProperties) {
            propertyNames.append(".ExtendedProperties")
        }
        if self.contains(.NotifyEncryptionRequired) {
            propertyNames.append(".NotifyEncryptionRequired")
        }
        if self.contains(.IndicateEncryptionRequired) {
            propertyNames.append(".IndicateEncryptionRequired")
        }

        return "[\(propertyNames.joinWithSeparator(","))]"
    }
}

extension CBCharacteristicProperties: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}