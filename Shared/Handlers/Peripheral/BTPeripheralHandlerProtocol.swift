//
//  BTPeripheralHandlerProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation
import CoreBluetooth

@objc protocol BTPeripheralHandlerProtocol: class {

    // MARK: Peripheral's name updated
    
    optional func peripheralDidUpdateName(peripheral: BTPeripheralAPIType)
    
    // MARK: Services and characteristics discovered
    
    optional func peripheral(peripheral: BTPeripheralAPIType,
        didDiscoverServices error: NSError?)
    
    optional func peripheral(peripheral: BTPeripheralAPIType,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?)
    
    // MARK: Value for characteristics updated/wrote
    
    optional func peripheral(peripheral: BTPeripheralAPIType,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?)
    
    optional func peripheral(peripheral: BTPeripheralAPIType,
        didWriteValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?)
    
    // MARK: Notification state for characteristics updated
    
    optional func peripheral(peripheral: BTPeripheralAPIType,
        didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic,
        error: NSError?)
}
