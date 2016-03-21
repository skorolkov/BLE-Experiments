//
//  BTMockCentralManager.swift
//  BLE-Experiments
//
//  Created by d503 on 3/18/16.
//
//

import Foundation
import CoreBluetooth

@objc class BTMockCentralManager: NSObject, BTCentralManagerInitializibleProtocol {
    
    // MARK: Delegate
    
    weak var delegate: CBCentralManagerDelegate?
    
    // MARK: State
    
    private(set) var state: CBCentralManagerState
    
    // MARK: Private Properties
    
    private var delegateQueue: dispatch_queue_t
    
    private var discoveredPeripherals: [CBPeripheral] = []
    private var connectedPeripherals: [CBPeripheral] = []
    
    // MARK: Initialization
    
    required init(delegate: CBCentralManagerDelegate?,
        queue: dispatch_queue_t?,
        options: [String : AnyObject]?) {
        
            self.state = .Unknown
            self.delegate = delegate
            self.delegateQueue = queue ?? dispatch_get_main_queue()
    }
    
    // MARK: CBCentralManager methods
    
    func scanForPeripheralsWithServices(serviceUUIDs: [CBUUID]?, options: [String : AnyObject]?) {
        
    }
    
    func stopScan() {
        
    }
    
    func retrievePeripheralsWithIdentifiers(identifiers: [NSUUID]) -> [CBPeripheral] {
        return []
    }
    
    func retrieveConnectedPeripheralsWithServices(serviceUUIDs: [CBUUID]) -> [CBPeripheral] {
        return []
    }
    
    func connectPeripheral(peripheral: CBPeripheral, options: [String : AnyObject]?) {
        
    }
    
    func cancelPeripheralConnection(peripheral: CBPeripheral) {
        
    }
    
    // MARK: Testing Utility methods
    
    func updateState(state: CBCentralManagerState) {
        self.state = state
    }
    
    func addDiscoveredPeripheral(peripheral: CBPeripheral) {
        discoveredPeripherals.append(peripheral)
    }
}
