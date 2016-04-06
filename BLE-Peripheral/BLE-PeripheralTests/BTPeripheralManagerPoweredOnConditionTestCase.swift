//
//  BTPeripheralManagerPoweredOnConditionTestCase.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import XCTest
import Operations
@testable import BLE_Peripheral

class BTPeripheralManagerPoweredOnConditionTestCase: BTBaseOperationTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testConditionEvaluation() {
        
        let peripheralManager = BTStubPoweredOffPeripheralManager()
        
        let condition = BTPeripheralManagerPoweredOnCondition(withPeripheralManager: peripheralManager)
        
        let poweredOfExpectation = expectationWithDescription("Bluetooth state is PoweredOn")
        
        condition.evaluateForOperation(Operation()) { (result: OperationConditionResult) in
            if case OperationConditionResult.Failed(_) = result {
                poweredOfExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testConditionDependencyOperation() {
        let peripheralManager = BTStubPoweredOffPeripheralManager()
        
        let condition = BTPeripheralManagerPoweredOnCondition(withPeripheralManager: peripheralManager)
        
        let operation = Operation()
        
        operation.addCondition(condition)
        
        let poweredOfExpectation = expectationWithDescription("Bluetooth state is PoweredOn")

        operation.addObserver(DidFinishObserver { (operation, errors) in
            if operation.finished && errors.isEmpty {
                poweredOfExpectation.fulfill()
            }
            })
        
        operationQueue.addOperation(operation)
        
        peripheralManager.state = .PoweredOn
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
