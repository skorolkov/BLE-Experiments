//
//  BTPeripheralManagerPoweredOnCondition.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations
import CoreBluetooth

class BTPeripheralManagerPoweredOnCondition: BTBaseCondition {
    
    // MARK: Private Properties
    
    private unowned var peripheralManager: BTPeripheralManagerAPIType
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        self.peripheralManager = peripheralManager
        super.init(mutuallyExclusive: false)
    }
    
    override func evaluate(operation: Operation, completion: OperationConditionResult -> Void) {
        if peripheralManager.managerState == .PoweredOn {
            completion(.Satisfied)
        }
        else {
            let error = BTPeripheralManagerStateInvalidError(withExpectedState: .PoweredOn,
                realState: peripheralManager.managerState)
            completion(.Failed(error))
        }
    }
}

class BTPeripheralManagerPoweredOnWaitingCondition: BTPeripheralManagerPoweredOnCondition {
    
    override init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        super.init(withPeripheralManager: peripheralManager)
        addDependency(BTPeripheralManagerPoweredOnWaitingOperation(
            withPeripheralManager: peripheralManager))
    }
}

class BTPeripheralManagerPoweredOnWaitingOperation: BTPeripheralManagerOperation {
    
    override func execute() {
        guard !cancelled else { return }
        
        guard peripheralManager?.managerState != .PoweredOn else {
            finish()
            return
        }
        
        peripheralManager?.addHandler(self)
    }
}

extension BTPeripheralManagerPoweredOnWaitingOperation: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        if peripheral.managerState == .PoweredOn {
            removeHandlerAndFinish()
        }
    }
}
