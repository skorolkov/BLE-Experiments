//
//  BTCentralManagerAPIWithHadlerProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/11/16.
//
//

import Foundation

@objc protocol BTCentralManagerAPIWithHadlerProtocol: BTCentralManagerAPIProtocol {
    
    // MARK: Add handler
    
    func addHandler(handlerToAdd: BTCentralManagerHandlerProtocol)
    
    func removeHandler(handlerToRemove: BTCentralManagerHandlerProtocol)
}