//
//  BTPeripheralBlockHandler.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation
import CoreBluetooth

/**
 * Some methods of BTPeripheralHandlerProtocol are optional, so class should be declared as @objc class,
 * and (as required by usage of '@objc' directive) it must inherit NSObject class
 */

@objc class BTPeripheralBlockHandler: BTCustomQueueHandler {
    
    // MARK: Typenames
    
    typealias BTPeripheralUpdateNameBlock = (peripheral: BTPeripheralAPIType) -> Void
    
    typealias BTPeripheralServicesDiscoveryBlock = (peripheral: BTPeripheralAPIType, error: NSError?) -> Void
    
    typealias BTPeripheralCharactDicoveryBlock = (peripheral: BTPeripheralAPIType,
        service: CBService,
        error: NSError?) -> Void
    
    typealias BTPeripheralCharactUpdateWriteBlock = (peripheral: BTPeripheralAPIType,
        characteristic: CBCharacteristic,
        error: NSError?) -> Void
    
    // MARK: Internal Properties
    
    var didUpdateNameBlock: BTPeripheralUpdateNameBlock? = nil
    var didDiscoverServicesBlock: BTPeripheralServicesDiscoveryBlock? = nil
    var didDiscoverCharacteristicsBlock: BTPeripheralCharactDicoveryBlock? = nil
    var didUpdateValueForCharacteristicBlock: BTPeripheralCharactUpdateWriteBlock? = nil
    var didWriteValueForCharacteristicBlock: BTPeripheralCharactUpdateWriteBlock? = nil
    var didUpdateNotificationStateForCharacteristicBlock: BTPeripheralCharactUpdateWriteBlock? = nil
}

// MARK: BTPeripheralHandlerProtocol

extension BTPeripheralBlockHandler: BTPeripheralHandlerProtocol {
    
    // MARK: Updating peripheral's name
    
    func peripheralDidUpdateName(peripheral: BTPeripheralAPIType) {
        dispatch_async(queue) { [unowned self] () -> Void in
            self.didUpdateNameBlock?(peripheral: peripheral)
        }
    }
    
    // MARK: Discovering services and characteristics
    
    func peripheral(peripheral: BTPeripheralAPIType,
        didDiscoverServices error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didDiscoverServicesBlock?(peripheral: peripheral, error: error)
            }
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didDiscoverCharacteristicsBlock?(peripheral: peripheral,
                    service: service,
                    error: error)
            }
    }
    
    // MARK: Updating/writing value for characteristics
    
    func peripheral(peripheral: BTPeripheralAPIType,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didUpdateValueForCharacteristicBlock?(peripheral: peripheral,
                    characteristic: characteristic,
                    error: error)
            }
    }
    
    func peripheral(peripheral: BTPeripheralAPIType,
        didWriteValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didWriteValueForCharacteristicBlock?(peripheral: peripheral,
                    characteristic: characteristic,
                    error: error)
            }
    }
    
    // MARK: Updating notification state for characteristics
    
    func peripheral(peripheral: BTPeripheralAPIType,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didUpdateNotificationStateForCharacteristicBlock?(peripheral: peripheral,
                    characteristic: characteristic,
                    error: error)
            }
    }
}
