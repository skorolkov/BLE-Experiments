//
//  BTBaseOperationTestCase.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import XCTest
import Operations

class BTBaseOperationTestCase: XCTestCase {
    
    private(set) var operationQueue: OperationQueue = OperationQueue()
    
    override func setUp() {
        super.setUp()
        
        operationQueue = OperationQueue()
        
        let queueName = "\(self.name)/.queue"
        operationQueue.name = queueName
        operationQueue.underlyingQueue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT)
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
