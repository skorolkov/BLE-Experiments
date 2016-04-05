//
//  BTAddServicesOperation.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/23/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Operations
import CoreBluetooth

class BTAddServicesOperation: BTPeripheralManagerOperation {
    
    // MARK: Properties
    
    private var services: [BTService]
    
    // MARK: Initializers
    
    init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType,
        peripheralRolePerformer: BTPeripheralRolePerformer,
        services: [BTService]) {
            self.services = services
            super.init(withPeripheralManager: peripheralManager)
            
            addCondition(MutuallyExclusive<BTPeripheralManagerProxy>())
            addCondition(BTServiceNotAddedCondition(withPeripheralRolePerformer: peripheralRolePerformer))
    }
    
    private override init(withPeripheralManager peripheralManager: BTPeripheralManagerAPIType) {
        services = []
        super.init(withPeripheralManager: peripheralManager)
        fatalError()
    }
    
    override func execute() {
        peripheralManager?.addHandler(self)
        
        services.map { $0.coreBluetoothService() }.forEach { (service: CBMutableService) -> () in
            peripheralManager?.addService(service)
        }
    }
}

extension BTAddServicesOperation: BTPeripheralManagerHandlerProtocol {
    
    func peripheralManagerDidUpdateState(peripheral: BTPeripheralManagerAPIType) {
        // nothing to do here
    }
    
    func peripheralManager(peripheral: BTPeripheralManagerAPIType, didAddService service: CBService, error: NSError?) {
        
        peripheralManager?.removeHandler(self)
        
        if let error = error {
            finish(error)
        }
        else {
            finish()
        }
    }
}
