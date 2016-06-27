//
//  BTPeripheralProviding.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/30/16.
//  Copyright © 2016 d503. All rights reserved.
//

import ReactiveCocoa
import Result

typealias BTPeripheralSignal = Signal<[BTPeripheral], NoError>

protocol BTPeripheralProviding {
    
    var peripherals: AnyProperty<[BTPeripheral]> { get }
    
    func peripheralsUpdatedSignal() -> BTPeripheralSignal
}