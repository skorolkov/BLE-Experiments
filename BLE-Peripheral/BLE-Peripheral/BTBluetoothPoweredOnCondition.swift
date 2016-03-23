//
//  BTOperations.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/22/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
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
    
    private unowned var peripheralManager: BTPeripheralManagerProxy
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerProxy) {
        self.peripheralManager = peripheralManager
        super.init(mutuallyExclusive: false)
    }
    
    // MARK: OperationCondition protocol
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return BTBluetoothPowerOnWaitingOperation(withPeripheralManager: peripheralManager)
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

class BTBluetoothPowerOnWaitingOperation: BTPeripheralManagerOperation {
    
    override func execute() {
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