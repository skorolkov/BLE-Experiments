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

public final class BTPeripheralDataProvider: NSObject, BTPeripheralUpdating, BTPeripheralProviding {
    
    // MARK: Public Properties
    public var peripherals: AnyProperty<[BTPeripheral]> {
        return AnyProperty(peripheralsToUpdate)
    }
    public var centralManagerState: AnyProperty<BTManagerState> {
        return AnyProperty(centralManagerStateToUpdate)
    }
    public var isScanningForPeripherals: AnyProperty<Bool> {
        return AnyProperty(scanningForPeripheralsToUpdate)
    }
    
    //MARK: Internal Properties
    var peripheralsToUpdate: MutableProperty<[BTPeripheral]> = MutableProperty([])
    
    var centralManagerStateToUpdate: MutableProperty<BTManagerState> = MutableProperty(.Unknown)
    
    var scanningForPeripheralsToUpdate: MutableProperty<Bool> = MutableProperty(false)
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
}
