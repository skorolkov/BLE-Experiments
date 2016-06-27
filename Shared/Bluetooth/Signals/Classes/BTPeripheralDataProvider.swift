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
    
    // MARK: Private Properties
    
    private var signal: BTPeripheralSignal
    private var observer: BTPeripheralSignal.Observer
    
    // MARK: Initializers
    
    override init() {
        (self.signal, self.observer) = BTPeripheralSignal.pipe()
        super.init()
    }
    
    // MARK: Internal Methods
    
    func peripheralsUpdatedSignal() -> BTPeripheralSignal {
        return signal
    }
    
    func peripheralsUpdatedSignalObserver() -> BTPeripheralSignalObserver {
        return observer
    }
}