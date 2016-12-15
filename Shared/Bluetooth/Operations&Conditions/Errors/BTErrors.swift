//
//  BTErrors.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

class BTError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    // MARK: CustomStringConvertible
    var description: String {
        return "<\(self.dynamicType)>"
    }
    
    // MARK: CustomDebugStringConvertible
    var debugDescription: String {
        return description
    }
}

final class BTCentralManagerStateInvalidError: BTError {
    
    let expectedState: BTManagerState
    let realState: BTManagerState
    
    init(withExpectedState expectedState: BTManagerState, realState: BTManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
    
    // MARK: CustomStringConvertible
    override var description: String {
        return "<\(self.dynamicType): expectedState=\(expectedState), realState=\(realState)>"
    }
}

final class BTPeripheralManagerStateInvalidError: BTError {
    
    let expectedState: BTManagerState
    let realState: BTManagerState
    
    init(withExpectedState expectedState: BTManagerState, realState: BTManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
    
    // MARK: CustomStringConvertible
    override var description: String {
        return "<\(self.dynamicType): expectedState=\(expectedState), realState=\(realState)>"
    }
}

final class BTPeripheralStateInvalidError: BTError {
    
    let expectedState: CBPeripheralState
    let realState: CBPeripheralState
    
    init(withExpectedState expectedState: CBPeripheralState, realState: CBPeripheralState) {
        self.expectedState = expectedState
        self.realState = realState
    }
    
    // MARK: CustomStringConvertible
    override var description: String {
        return "<\(self.dynamicType): expectedState=\(expectedState), realState=\(realState)>"
    }
}

class BTWrapperError: BTError {
    let originalError: NSError?
    
    init(originalError: NSError?) {
        self.originalError = originalError
    }
    
    // MARK: CustomStringConvertible
    override var description: String {
        return "<\(self.dynamicType): originalError=\(originalError)>"
    }
}

final class BTCentralManagerFailToConnectPeripheralError: BTWrapperError {}

final class BTCentralManagerDidDisconnectPeripheralError: BTWrapperError {}

final class BTPeriphalServiceDiscoveryError: BTWrapperError {}

final class BTPeriphalCharacteristicDiscoveryError: BTWrapperError {}

class BTCharacteristicError: BTError {
    let characteristicUUID: CBUUID
    let originalError: NSError?
    
    init(characteristicUUID: CBUUID, originalError: NSError?) {
        self.characteristicUUID = characteristicUUID
        self.originalError = originalError
    }
    
    // MARK: CustomStringConvertible
    override var description: String {
        return "<\(self.dynamicType): characteristicUUID=\(characteristicUUID), originalError =\(originalError)>"
    }
}

final class BTPeripheralUpdateValueForCharacteristicError: BTCharacteristicError {}

final class BTPeripheralWriteValueForCharacteristicError: BTCharacteristicError {}

final class BTPeripheralUpdateNotificationStateForCharacteristicError: BTCharacteristicError {}

final class BTOperationError: BTError {
    
    enum Code {
        case OperationFailed(errors: [ErrorType])
        case OperationTypeMismatch
    }
    
    let code: Code
    
    init(code: Code) {
        self.code = code
    }
    
    // MARK: CustomStringConvertible
    override var description: String {
        return "<\(self.dynamicType): code=\(code)>"
    }
    
}
