//
//  BTHandlersContainer.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation

class BTHandlersContainer<Handler: NSObjectProtocol>: BTHandlerContainerProtocol {
    
    // MARK: Internal Properties
    
    private(set) var handlers: [Handler] = []
    
    // MARK: BTHandlerContainerProtocol
    
    func addHandler(handlerToAdd: Handler) {
        guard indexOfHandler(handlerToAdd) == nil else {
            return
        }
        
        handlers.append(handlerToAdd)
    }
    
    func removeHandler(handlerToRemove: Handler) {
        guard let index = indexOfHandler(handlerToRemove) else {
            return
        }
        
        handlers.removeAtIndex(index)
    }
    
    private func indexOfHandler(handlerToFind: Handler) -> Int? {
        return handlers.indexOf { (handler: Handler) -> Bool in
            return handler.isEqual(handlerToFind)
        }
    }
}
