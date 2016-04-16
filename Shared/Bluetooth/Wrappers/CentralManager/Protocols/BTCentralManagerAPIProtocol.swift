//
//  CentralManagerProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/7/16.
//
//

import CoreBluetooth

@objc protocol BTCentralManagerAPIProtocol: class {
    
    // MARK: State
    
    var state: CBCentralManagerState { get }
    
    // MARK: Scan for peripherals
    
    func scanForPeripheralsWithServices(serviceUUIDs: [CBUUID]?, options: [String : AnyObject]?)
    
    func stopScan()
    
    // MARK: Retrieving peripherals
    
    func retrievePeripheralsWithIdentifiers(identifiers: [NSUUID]) -> [CBPeripheral]
    
    func retrieveConnectedPeripheralsWithServices(serviceUUIDs: [CBUUID]) -> [CBPeripheral]
    
    // MARK: Connecting to peripherals
    
    func connectPeripheralWithObject(peripheral: BTPeripheralAPIType, options: [String : AnyObject]?)
    
    // MARK: Disconnecting from peripherals
    
    func cancelPeripheralConnectionWithObject(peripheral: BTPeripheralAPIType)
}
