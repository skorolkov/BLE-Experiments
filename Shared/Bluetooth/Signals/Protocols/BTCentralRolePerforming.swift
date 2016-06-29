//
//  BTCentralRolePerforming.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import Operations

protocol BTCentralRolePerforming: class {
    var operationQueue: OperationQueue { get }

    func updateManagedPeripheral(peripheral: BTPeripheralAPIType)

    func updateModelPeripheral(peripheral: BTPeripheral)
}