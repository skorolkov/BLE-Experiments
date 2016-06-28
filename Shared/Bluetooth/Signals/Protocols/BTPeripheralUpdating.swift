//
//  BTPeripheralUpdating.swift
//  PowerDot-Athlete
//
//  Created by d503 on 5/31/16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import ReactiveCocoa
import Result

protocol BTPeripheralUpdating {
   
    var scannedPeripheralsToUpdate: MutableProperty<[BTPeripheral]> { get set }

    var peripheralsToUpdate: MutableProperty<[BTPeripheral]> { get set }
}