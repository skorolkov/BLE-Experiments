//
//  BTCentralManagerConnectiongOperationTestCase.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/10/16.
//  Copyright © 2016 d503. All rights reserved.
//

import XCTest
import CoreBluetooth
import Operations
@testable import BLE_Central_OSX

class BTCentralManagerConnectiongOperationTestCase: BTBaseOperationTestCase {
    
    private var identifier: NSUUID!
    
    override func setUp() {
        super.setUp()
        
        identifier = NSUUID(UUIDString: "19151B7D-2CD0-4AFC-AE88-8D03993AC46F")!
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCentralManagerIsPoweredOff() {
        
        let centralManager = BTStubSuccessConnectionCentralManager()
        centralManager.state = .PoweredOff
        
        let peripheral = BTBaseStubPeripheral(identifier: identifier)

        let operation = BTCentralManagerConnectingOperation(
        centralManager: centralManager,
        peripheral: peripheral)
        
        let connectionFinishedExpectation = expectationWithDescription("connection to peripherals finished")
        
        operation.addObserver(DidFinishObserver { (operation, errors) in
            if operation.finished && !errors.isEmpty {
                if let error = errors.first where error is BTCentralManagerStateInvalidError {
                    connectionFinishedExpectation.fulfill()
                }
            }
            })
        
        operationQueue.addOperation(operation)
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testSuccessConnectionOperation() {
        
        let centralManager = BTStubSuccessConnectionCentralManager()
        centralManager.state = .PoweredOn
        
        let peripheral = BTBaseStubPeripheral(identifier: identifier)
        
        let operation = BTCentralManagerConnectingOperation(
            centralManager: centralManager,
            peripheral: peripheral)
        
        let connectionFinishedExpectation = expectationWithDescription("connection to peripherals finished")
        
        operation.addObserver(DidFinishObserver { (operation, errors) in
            guard operation.finished && errors.isEmpty else {
                XCTFail("expected operation to finish without errors")
                return
            }
            
            guard let connectionOperation = operation as? BTCentralManagerConnectingOperation else {
                XCTFail("expected operation to be instance of BTCentralManagerScanningOperation class")
                return
            }
            
            if connectionOperation.updatedPeripheral != nil {
                connectionFinishedExpectation.fulfill()
            }
            })
        
        operationQueue.addOperation(operation)
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testFailedConnectionOperation() {
        
        let centralManager = BTStubFailedConnectionCentralManager()
        centralManager.state = .PoweredOn
        
        let peripheral = BTBaseStubPeripheral(identifier: identifier)
        
        let operation = BTCentralManagerConnectingOperation(
            centralManager: centralManager,
            peripheral: peripheral)
        
        let connectionFinishedExpectation = expectationWithDescription("connection to peripherals finished")
        
        operation.addObserver(DidFinishObserver { (operation, errors) in
            guard operation.finished else {
                XCTFail("expected operation to finish")
                return
            }
            
            guard let connectionOperation = operation as? BTCentralManagerConnectingOperation else {
                XCTFail("expected operation to be instance of BTCentralManagerScanningOperation class")
                return
            }
            
            if connectionOperation.updatedPeripheral == nil {
                connectionFinishedExpectation.fulfill()
            }
            })
        
        operationQueue.addOperation(operation)
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testConnectionCancellation() {
        
        let centralManager = BTStubSuccessConnectionCentralManager()
        centralManager.state = .PoweredOn
        
        let peripheral = BTBaseStubPeripheral(identifier: identifier)
        
        let operation = BTCentralManagerConnectingOperation(
            centralManager: centralManager,
            peripheral: peripheral)
        
        let connectionCancelledExpectation = expectationWithDescription("connection to peripherals finished")
        
        operation.addObserver(DidFinishObserver { (operation, errors) in
            guard operation.cancelled else {
                XCTFail("expected operation to finish without errors")
                return
            }
            
            connectionCancelledExpectation.fulfill()
            })
        
        operationQueue.addOperation(operation)
        
        operation.cancel()
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
