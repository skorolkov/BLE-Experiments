//
//  BTServiceNotAddedCondition.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

struct BTServiceAlreadyAddedError: ErrorType { }

class BTServiceNotAddedCondition: BTBaseCondition, OperationCondition {
    
    // MARK: Private Properties
    
    private unowned var peripheralRolePerformer: BTPeripheralRolePerformer
    
    // MARK: Initializers
    
    init(withPeripheralRolePerformer peripheralRolePerformer: BTPeripheralRolePerformer) {
        self.peripheralRolePerformer = peripheralRolePerformer
        super.init(mutuallyExclusive: false)
    }
    
    // MARK: OperationCondition protocol
    
    func dependencyForOperation(operation: Operation) -> NSOperation? {
        return .None
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void) {
        if peripheralRolePerformer.servicesAdded {
            completion(.Failed(BTServiceAlreadyAddedError()))
        }
        else {
            completion(.Satisfied)
        }
    }
}