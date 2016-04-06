//
//  BTcentralManagerPoweredOnCondtionTetsCase.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import XCTest
import Operations
@testable import BLE_Central_OSX

class BTcentralManagerPoweredOnCondtionTetsCase: BTBaseOperationTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testConditionEvaluation() {
        
        let centralManager = BTStubPoweredOffCentralManager()
        
        let condition = BTCentralManagerPoweredOnCondition(withCentralManager: centralManager)
        
        let poweredOfExpectation = expectationWithDescription("Bluetooth state is PoweredOn")
        
        condition.evaluateForOperation(Operation()) { (result: OperationConditionResult) in
            if case OperationConditionResult.Failed(_) = result {
                poweredOfExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testConditionDependencyOperation() {
        let centralManager = BTStubPoweredOffCentralManager()
        
        let condition = BTCentralManagerPoweredOnCondition(withCentralManager: centralManager)
        
        let operation = Operation()
        
        operation.addCondition(condition)
        
        let poweredOfExpectation = expectationWithDescription("Bluetooth state is PoweredOn")

        operation.addObserver(DidFinishObserver { (operation, errors) in
            if operation.finished && errors.isEmpty {
                poweredOfExpectation.fulfill()
            }
            })
        
        operationQueue.addOperation(operation)
        
        centralManager.state = .PoweredOn
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
