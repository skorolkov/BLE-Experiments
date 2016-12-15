//
//  BTCentralManagerScanningOperationTestCase.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

import XCTest
import Operations
@testable import BLE_Central_OSX

class BTCentralManagerScanningOperationTestCase: BTBaseOperationTestCase {

    private var centralManager: BTStubScanCentralManager!
    
    override func setUp() {
        super.setUp()
        
        centralManager = BTStubScanCentralManager()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testCentralManagerIsPoweredOff() {
        
        centralManager.managerState = .PoweredOff
        
        let operation = BTCentralManagerScanningOperation(
            centralManager: centralManager,
            stopScanningCondition: { (discoveredPeripherals) -> Bool in
                return discoveredPeripherals.count >= 2
        })
        
        let scanningFinishedExpectation = expectationWithDescription("scan for peripherals finished")
        
        operation.addObserver(DidFinishObserver { (operation, errors) in
            if operation.finished && !errors.isEmpty {
                if let error = errors.first where error is BTCentralManagerStateInvalidError {
                    scanningFinishedExpectation.fulfill()
                }
            }
            })
        
        operationQueue.addOperation(operation)
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testScanningOperation() {
        
        centralManager.managerState = .PoweredOn
        
        let operation = BTCentralManagerScanningOperation(
            centralManager: centralManager,
            stopScanningCondition: { (discoveredPeripherals) -> Bool in
                return discoveredPeripherals.count >= 2
        })
        
        let scanningFinishedExpectation = expectationWithDescription("scan for peripherals finished")
        
        operation.addObserver(DidFinishObserver { (operation, errors) in
            guard operation.finished && errors.isEmpty else {
                XCTFail("expected operation to finish without errors")
                return
            }
            
            guard let scanOperation = operation as? BTCentralManagerScanningOperation else {
                XCTFail("expected operation to be instance of BTCentralManagerScanningOperation class")
                return
            }
            
            if scanOperation.discoveryResults.count == 2 {
                scanningFinishedExpectation.fulfill()
            }
        })
        
        operationQueue.addOperation(operation)
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testScanningCancellation() {
        
        centralManager.managerState = .PoweredOn
        
        let operation = BTCentralManagerScanningOperation(
            centralManager: centralManager,
            stopScanningCondition: { (discoveredPeripherals) -> Bool in
                return discoveredPeripherals.count >= 2
        })
        
        let scanningCancelledExpectation = expectationWithDescription("scan for peripherals cancelled")
        
        operation.addObserver(DidFinishObserver { (operation, errors) in
            guard operation.cancelled else {
                XCTFail("expected operation to finish without errors")
                return
            }
            
            scanningCancelledExpectation.fulfill()
        })
        
        operationQueue.addOperation(operation)
        
        operation.cancelWithError()
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
}
