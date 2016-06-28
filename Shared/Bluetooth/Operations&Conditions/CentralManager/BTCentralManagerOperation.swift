//
//  BTCentralManagerOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import Operations

class BTCentralManagerOperation: BTOperation {
    
    // MARK: Private Properties
    
    private(set) weak var centralManager: BTCentralManagerAPIType?
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType) {
        self.centralManager = centralManager
    }
    
    // MARK: Internal Methods
    
    func removeHandlerAndFinish(error: ErrorType? = nil) {
        if let handler = self as? BTCentralManagerHandlerProtocol {
            centralManager?.removeHandler(handler)
        }
        finish(error)
    }
}