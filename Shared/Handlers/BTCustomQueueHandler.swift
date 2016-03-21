//
//  CustomQueueHandler.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation

class BTCustomQueueHandler: NSObject {
    
    // MARK: Internal propeties
    
    private(set) var queue: dispatch_queue_t
    
    override init() {
        queue = dispatch_get_main_queue()
        super.init()
    }
    
    init(withHandlerQueue queue: dispatch_queue_t) {
        self.queue = queue
        super.init()
    }
}