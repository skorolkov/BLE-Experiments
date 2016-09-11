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
    
    // MARK: Private Properies
    
    private let accessQueue: dispatch_queue_t
    
    // MARK: Initialization

    init() {
        accessQueue = dispatch_queue_create("BTHandlerContainer SynchronizedAccess",
                                            DISPATCH_QUEUE_SERIAL)
    }
    
    // MARK: BTHandlerContainerProtocol
    
    func addHandler(handlerToAdd: Handler) {
        dispatch_async(accessQueue) {
            guard self.indexOfHandler(handlerToAdd) == nil else {
                return
            }
            
            self.handlers.append(handlerToAdd)
        }
    }
    
    func removeHandler(handlerToRemove: Handler) {
        dispatch_async(accessQueue) {
            guard let index = self.indexOfHandler(handlerToRemove) else {
                return
            }
            
            self.handlers.removeAtIndex(index)
        }
    }

    func removeAllHandlers() {
        dispatch_async(accessQueue) {
            self.handlers.removeAll()
        }
    }
    
    private func indexOfHandler(handlerToFind: Handler) -> Int? {
        return handlers.indexOf { (handler: Handler) -> Bool in
            return handler.isEqual(handlerToFind)
        }
    }
}
