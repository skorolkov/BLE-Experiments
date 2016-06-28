//
//  OperationQueueAPI.swift
//  PowerDot-Athlete
//
//  Created by d503 on 3/30/16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Operations

protocol OperationQueueAPI: class {
    func addOperation(operation: NSOperation)
    
    func addOperations(ops: [NSOperation], waitUntilFinished wait: Bool)
    
    func addOperations(ops: [NSOperation])
    
    func addOperations(ops: NSOperation...)
    
    func cancelAllOperations()
}

extension OperationQueue: OperationQueueAPI {}
