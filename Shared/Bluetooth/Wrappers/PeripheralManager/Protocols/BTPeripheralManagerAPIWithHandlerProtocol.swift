//
//  BTPeripheralManagerAPIWithHandlersProtocol.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol BTPeripheralManagerAPIWithHadlerProtocol: BTPeripheralManagerAPIProtocol {
    
    // MARK: Add handler
    
    func addHandler(handlerToAdd: BTPeripheralManagerHandlerProtocol)
    
    func removeHandler(handlerToRemove: BTPeripheralManagerHandlerProtocol)
}