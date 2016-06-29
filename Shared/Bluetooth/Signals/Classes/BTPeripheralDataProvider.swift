//
//  BTPeripheralDataProvider.swift
//  PowerDot-Athlete
//
//  Created by d503 on 5/31/16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

class BTPeripheralDataProvider: NSObject, BTPeripheralUpdating, BTPeripheralProviding {
    
    // MARK: Internal Properties
    
    var peripherals: AnyProperty<[BTPeripheral]> {
        return AnyProperty(peripheralsToUpdate)
    }
    var peripheralsToUpdate: MutableProperty<[BTPeripheral]> = MutableProperty([])
        
    // MARK: Initializers
    
    override init() {
        super.init()
    }
}