//
//  BTBluetoothPoweredOnWaitingCondition.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations
import CoreBluetooth

struct BTBluetoothStateMismatch: ErrorType {
    
    let expectedState: CBPeripheralManagerState
    let realState: CBPeripheralManagerState
    
    init(withExpectedState expectedState: CBPeripheralManagerState, realState: CBPeripheralManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
}

class BTBluetoothPoweredOnCondition: BTBaseCondition, OperationCondition {
    
    // MARK: Private Properties
    
    private unowned var peripheralManager: BTPeripheralManagerAPIType
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        self.peripheralManager = peripheralManager
        super.init(mutuallyExclusive: false)
    }

    // MARK: OperationCondition protocol
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return .None
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        if peripheralManager.state == .PoweredOn {
            completion(.Satisfied)
        }
        else {
            let error = BTBluetoothStateMismatch(withExpectedState: .PoweredOn,
                realState: peripheralManager.state)
            completion(.Failed(error))
        }
    }
}

class BTBluetoothPoweredOnWaitingCondition: BTBluetoothPoweredOnCondition {
    
    // MARK: OperationCondition protocol
    
    override func dependencyForOperation(operation: Operation) -> NSOperation? {
        return BTBluetoothPowerOnWaitingOperation(withPeripheralManager: peripheralManager)
    }
}

class BTBluetoothPowerOnWaitingOperation: BTPeripheralManagerOperation {
    
    override func execute() {
        guard peripheralManager?.state != .PoweredOn else {
            finish()
            return
        }
        
        peripheralManager?.addHandler(self)
    }
}

extension BTBluetoothPowerOnWaitingOperation: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        if peripheral.state == .PoweredOn {
            peripheralManager?.removeHandler(self)
            finish()
        }
    }
}