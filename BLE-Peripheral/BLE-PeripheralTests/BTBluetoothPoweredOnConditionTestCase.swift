//
//  BTBluetoothPoweredOnConditionTestCase.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import XCTest
import Operations
@testable import BLE_Peripheral

class BTBluetoothPoweredOnConditionTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testConditionEvaluation() {
        
        let peripheralManager = BTStubPoweredOffPeripheralManagers()
        
        let condition = BTBluetoothPoweredOnWaitingCondition(withPeripheralManager: peripheralManager)
        
        let poweredOfExpectation = expectationWithDescription("")
        
        condition.evaluateForOperation(Operation()) { (result: OperationConditionResult) in
            if case OperationConditionResult.Failed(_) = result {
                poweredOfExpectation.fulfill()
            }
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
