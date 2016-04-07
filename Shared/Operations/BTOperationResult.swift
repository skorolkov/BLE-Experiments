//
//  BTOperationResult.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import Operations

enum BTOperationResult {
    case Unknown
    case Finished
    case Cancelled([ErrorType])
    case Failed([ErrorType])
    
    init(operation: Operation, errors: [ErrorType]) {
        
        if operation.finished {
            if errors.isEmpty {
                self = .Finished
            }
            else {
                self = .Failed(errors)
            }
        }
        else if operation.cancelled {
            self = .Cancelled(errors)
        }
        else {
            self = .Unknown
        }
    }
}
