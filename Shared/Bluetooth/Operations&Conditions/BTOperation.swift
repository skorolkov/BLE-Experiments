//
//  BTOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 6/28/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import Operations

class BTOperation: Operation {
    
    static let operationQueue: OperationQueueAPI = {
        return OperationQueue.operationQueueWithName("BTOperation")
    }()
    
    override init() {
        super.init()
        
        self.name = "\(NSStringFromClass(self.dynamicType))"
    }
}