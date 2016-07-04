//
//  BTPeripheralProxy+Description.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/3/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation

extension BTPeripheralProxy {
    override var description: String {
        return "<\(self.dynamicType): indentifier=\(identifier.UUIDString), name=\(name), state=\(state)>"
    }
    
    override var debugDescription: String {
        return description
    }
}