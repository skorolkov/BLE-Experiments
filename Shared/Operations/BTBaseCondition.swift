//
//  BTBaseCondition.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations

class BTBaseCondition {
    
    // MARK: Initializers

    init(mutuallyExclusive: Bool) {
        self.isMutuallyExclusive = mutuallyExclusive
    }
    
    // MARK: OperationCondition protocol
    
    var name: String {
        return NSStringFromClass(self.dynamicType)
    }
    
    private(set) var isMutuallyExclusive: Bool
}