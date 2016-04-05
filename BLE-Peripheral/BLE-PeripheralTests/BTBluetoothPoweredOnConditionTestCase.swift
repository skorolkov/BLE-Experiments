//
//  BTBluetoothPoweredOnConditionTestCase.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import XCTest
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
        
    }
}
