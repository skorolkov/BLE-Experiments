//
//  BTErrors.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

public class BTError: ErrorType, CustomStringConvertible, CustomDebugStringConvertible {
    // MARK: CustomStringConvertible
    public var description: String {
        return "<\(self.dynamicType)>"
    }
    
    // MARK: CustomDebugStringConvertible
    public var debugDescription: String {
        return description
    }
}

public final class BTCentralManagerStateInvalidError: BTError {
    
    public let expectedState: BTManagerState
    public let realState: BTManagerState
    
    public init(expectedState: BTManagerState, realState: BTManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
    
    // MARK: CustomStringConvertible
    override public var description: String {
        return "<\(self.dynamicType): expectedState=\(expectedState), realState=\(realState)>"
    }
}

public final class BTPeripheralManagerStateInvalidError: BTError {
    
    public let expectedState: BTManagerState
    public let realState: BTManagerState
    
    public init(expectedState: BTManagerState, realState: BTManagerState) {
        self.expectedState = expectedState
        self.realState = realState
    }
    
    // MARK: CustomStringConvertible
    override public var description: String {
        return "<\(self.dynamicType): expectedState=\(expectedState), realState=\(realState)>"
    }
}

public final class BTPeripheralStateInvalidError: BTError {
    
    public let expectedState: CBPeripheralState
    public let realState: CBPeripheralState
    
    public init(expectedState: CBPeripheralState, realState: CBPeripheralState) {
        self.expectedState = expectedState
        self.realState = realState
    }
    
    // MARK: CustomStringConvertible
    override public var description: String {
        return "<\(self.dynamicType): expectedState=\(expectedState), realState=\(realState)>"
    }
}

public class BTWrapperError: BTError {
    public let originalError: NSError?
    
    public init(originalError: NSError?) {
        self.originalError = originalError
    }
    
    // MARK: CustomStringConvertible
    override public var description: String {
        return "<\(self.dynamicType): originalError=\(originalError)>"
    }
}

public final class BTCentralManagerFailToConnectPeripheralError: BTWrapperError {}

public final class BTCentralManagerDidDisconnectPeripheralError: BTWrapperError {}

public final class BTPeriphalServiceDiscoveryError: BTWrapperError {}

public final class BTPeriphalCharacteristicDiscoveryError: BTWrapperError {}

public class BTCharacteristicError: BTError {
    public let characteristicUUID: CBUUID
    public let originalError: NSError?
    
    public init(characteristicUUID: CBUUID, originalError: NSError?) {
        self.characteristicUUID = characteristicUUID
        self.originalError = originalError
    }
    
    // MARK: CustomStringConvertible
    override public var description: String {
        return "<\(self.dynamicType): characteristicUUID=\(characteristicUUID), originalError =\(originalError)>"
    }
}

public final class BTPeripheralUpdateValueForCharacteristicError: BTCharacteristicError {}

public final class BTPeripheralWriteValueForCharacteristicError: BTCharacteristicError {}

public final class BTPeripheralUpdateNotificationStateForCharacteristicError: BTCharacteristicError {}

public final class BTOperationError: BTError {
    
    public enum Code {
        case OperationFailed(errors: [ErrorType])
        case OperationTypeMismatch
    }
    
    public let code: Code
    
    public init(code: Code) {
        self.code = code
    }
    
    // MARK: CustomStringConvertible
    override public var description: String {
        return "<\(self.dynamicType): code=\(code)>"
    }
    
}
