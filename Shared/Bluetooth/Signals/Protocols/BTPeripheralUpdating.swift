//
//  BTPeripheralUpdating.swift
//  PowerDot-Athlete
//
//  Created by d503 on 5/31/16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import CoreBluetooth
import ReactiveCocoa
import Result

protocol BTPeripheralUpdating {
    var peripheralsToUpdate: MutableProperty<[BTPeripheral]> { get set }
    
    var centralManagerStateToUpdate: MutableProperty<BTManagerState> { get set }
    
    var scanningForPeripheralsToUpdate: MutableProperty<Bool> { get set }
}
