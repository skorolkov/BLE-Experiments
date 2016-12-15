//
//  BTPeripheralDataProvider.swift
//  PowerDot-Athlete
//
//  Created by d503 on 5/31/16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReactiveCocoa
import Result

class BTPeripheralDataProvider: NSObject, BTPeripheralUpdating, BTPeripheralProviding {
    
    // MARK: Internal Properties
    
    var peripherals: AnyProperty<[BTPeripheral]> {
        return AnyProperty(peripheralsToUpdate)
    }
    
    var peripheralsToUpdate: MutableProperty<[BTPeripheral]> = MutableProperty([])
    
    var centralManagerState: AnyProperty<BTManagerState> {
        return AnyProperty(centralManagerStateToUpdate)
    }
    
    var centralManagerStateToUpdate: MutableProperty<BTManagerState> = MutableProperty(.Unknown)
    
    var isScanningForPeripherals: AnyProperty<Bool> {
        return AnyProperty(scanningForPeripheralsToUpdate)
    }
    
    var scanningForPeripheralsToUpdate: MutableProperty<Bool> = MutableProperty(false)
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
}
