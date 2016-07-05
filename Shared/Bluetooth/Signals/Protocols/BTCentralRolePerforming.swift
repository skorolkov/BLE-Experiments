//
//  BTCentralRolePerforming.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import Operations

protocol BTCentralRolePerforming: class {
    var operationQueue: OperationQueue { get }

    func updateManagedPeripheral(peripheral: BTPeripheralAPIType)

    func updateModelPeripheral(modelPeripheral: BTPeripheral)
    
    func modelPeripheralWithIdentifier(identifierString: String) -> BTPeripheral?
    
    func removeNotUsedModelPeripherals()
    
    func setScanningForPeripheralsInProgress(scanningInProgress: Bool)
}