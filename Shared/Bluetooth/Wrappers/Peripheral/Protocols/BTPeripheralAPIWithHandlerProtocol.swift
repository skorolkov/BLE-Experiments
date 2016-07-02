//
//  BTPeripheralAPIWithHandlerProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/11/16.
//
//

import Foundation

@objc protocol BTPeripheralAPIWithHandlerProtocol: BTPeripheralAPIProtocol {
    
    // MARK: Add handler
    
    func addHandler(handlerToAdd: BTPeripheralHandlerProtocol)
    
    func removeHandler(handlerToRemove: BTPeripheralHandlerProtocol)
    
    func removeAllHandlers()
}