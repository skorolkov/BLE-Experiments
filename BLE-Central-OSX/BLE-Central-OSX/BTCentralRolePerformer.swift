//
//  BTCentralRolePerformer.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth
import Operations

class BTCentralRolePerformer {
    
    // MARK: Private Properties
    
    private var centralManager: BTCentralManagerAPIWithHadlerProtocol
    
    // MARK: Operations
    
    private var operationQueue: OperationQueue

    // MARK: Initializers
    
    init() {
        operationQueue = OperationQueue()
        operationQueue.name = "\(self.dynamicType).queue"
        
        let bluetoothCentralManager = CBCentralManager(
            delegate: nil,
            queue: nil,
            options: [CBCentralManagerOptionShowPowerAlertKey : true])
        
        centralManager = BTCentralManagerProxy(centralManager: bluetoothCentralManager)
        
        //super.init()
    }
}
