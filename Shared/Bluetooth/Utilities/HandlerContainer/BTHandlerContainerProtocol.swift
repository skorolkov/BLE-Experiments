//
//  BTHandlerContainerProtocol.swift
//  BLE-Peripheral
//
//  Created by d503 on 4/5/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation

protocol BTHandlerContainerProtocol: class {
    
    associatedtype Handler
    
    func addHandler(handlerToAdd: Handler)
    
    func removeHandler(handlerToRemove: Handler)
    
    var handlers: [Handler] { get }
}