//
//  PeripheralProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/7/16.
//
//

import CoreBluetooth

@objc public protocol BTPeripheralAPIProtocol: class {

    var identifier: NSUUID { get }
    
    var name: String? { get }
    
    var state: CBPeripheralState { get }
    
    var services: [CBService]? { get }
    
    // MARK: Discover services and characterictics
    
    func discoverServices(serviceUUIDs: [CBUUID]?)
    
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, forService service: CBService)
    
    // MARK: Read value for characteristic
    
    func readValueForCharacteristic(characteristic: CBCharacteristic)
    
    // MARK: Write value for characteristic
    
    func writeValue(data: NSData, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType)
    
    // MARK: Subscribe on value update notifications for characteristic
    
    func setNotifyValue(enabled: Bool, forCharacteristic characteristic: CBCharacteristic)
    
    func coreBluetoothPeripheral() -> CBPeripheral
}

