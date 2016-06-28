//
//  OperarionQueue+Generation.swift
//  PowerDot-Athlete
//
//  Created by d503 on 6/21/16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Operations

extension OperationQueue {
    static func operationQueueWithName(
        name: String,
        attribute: dispatch_queue_attr_t = DISPATCH_QUEUE_CONCURRENT) -> OperationQueue {
        
        let operationQueue = OperationQueue()
        
        let queueName = "\(name).queue"
        
        operationQueue.name = queueName
        operationQueue.underlyingQueue = dispatch_queue_create(queueName, attribute)
        
        return operationQueue
    }
}