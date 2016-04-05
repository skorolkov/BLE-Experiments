//
//  PeripheralProxy.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation
import CoreBluetooth

@objc class BTPeripheralProxy: NSObject {
    
    // MARK: Private Properties
    
    private var peripheral: PeriphralFullAPIProtocol
    
    private var handlerContainer = BTHandlersContainer<BTPeripheralHandlerProtocol>()
    
    // MARK: Initializers
    
    init(peripheral: PeriphralFullAPIProtocol) {
        self.peripheral = peripheral
        super.init()
        
        self.peripheral.delegate = self
    }
}

// MARK: BTPeripheralAPIProtocol

extension BTPeripheralProxy: BTPeripheralAPIProtocol {
    
    var identifier: NSUUID {
        return peripheral.identifier
    }
    
    var name: String? {
        return peripheral.name
    }
    
    var state: CBPeripheralState {
        return peripheral.state
    }
    
    var services: [CBService]? {
        return peripheral.services
    }
    
    // MARK: Discover services and characterictics
    
    func discoverServices(serviceUUIDs: [CBUUID]?) {
        peripheral.discoverServices(serviceUUIDs)
    }
    
    func discoverCharacteristics(characteristicUUIDs: [CBUUID]?, forService service: CBService) {
        peripheral.discoverCharacteristics(characteristicUUIDs, forService: service)
    }
    
    // MARK: write value for characteristic
    
    func writeValue(data: NSData, forCharacteristic characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        peripheral.writeValue(data,
            forCharacteristic: characteristic,
            type: type)
    }
    
    // MARK: subscribe on value update notifications for characteristic
    
    func setNotifyValue(enabled: Bool, forCharacteristic characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(enabled, forCharacteristic: characteristic)
    }
}

extension BTPeripheralProxy: BTPeripheralAPIWithHandlerProtocol {
    
    func addHandler(handlerToAdd: BTPeripheralHandlerProtocol) {
        handlerContainer.addHandler(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: BTPeripheralHandlerProtocol) {
        handlerContainer.removeHandler(handlerToRemove)
    }
}

// MARK: CBPeripheralDelegate

extension BTPeripheralProxy: CBPeripheralDelegate {
    
    // MARK: Peripheral's name updated
    
    func peripheralDidUpdateName(peripheral: CBPeripheral) {
        handlerContainer.handlers.forEach { (handler: BTPeripheralHandlerProtocol) -> () in
            handler.peripheralDidUpdateName?(wrappedPeripheral(peripheral))
        }
    }
    
    // MARK: Services and characteristics discovered
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        handlerContainer.handlers.forEach { (handler: BTPeripheralHandlerProtocol) -> () in
            handler.peripheral?(wrappedPeripheral(peripheral), didDiscoverServices: error)
        }
    }
    
    func peripheral(peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?) {
            handlerContainer.handlers.forEach { (handler: BTPeripheralHandlerProtocol) -> () in
                handler.peripheral?(wrappedPeripheral(peripheral),
                    didDiscoverCharacteristicsForService: service,
                    error: error)
            }
    }
    
    // MARK: Value for characteristics updated/wrote
    
    func peripheral(peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
            handlerContainer.handlers.forEach { (handler: BTPeripheralHandlerProtocol) -> () in
                handler.peripheral?(wrappedPeripheral(peripheral),
                    didUpdateValueForCharacteristic: characteristic,
                    error: error)
            }
    }
    
    func peripheral(peripheral: CBPeripheral,
        didWriteValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
            handlerContainer.handlers.forEach { (handler: BTPeripheralHandlerProtocol) -> () in
                handler.peripheral?(wrappedPeripheral(peripheral),
                    didWriteValueForCharacteristic: characteristic,
                    error: error)
            }
    }
    
    // MARK: Notification state for characteristics updated
    
    func peripheral(peripheral: CBPeripheral,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
            handlerContainer.handlers.forEach { (handler: BTPeripheralHandlerProtocol) -> () in
                handler.peripheral?(wrappedPeripheral(peripheral),
                    didUpdateNotificationStateForCharacteristic: characteristic,
                    error: error)
            }
    }
}

// MARK: Supporting methods

private extension BTPeripheralProxy {
    
    func wrappedPeripheral(peripheral: CBPeripheral) -> BTPeripheralAPIType {
        return self
    }
}