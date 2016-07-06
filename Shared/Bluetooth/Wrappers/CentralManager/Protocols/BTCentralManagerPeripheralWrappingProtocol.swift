//
//  BTCentralManagerPeripheralWrappingProtocol.swift
//  BLE-Central-OSX
//
//  Created by d503 on 7/6/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BTCentralManagerPeripheralWrappingProtocol: class {
    func wrappedPeripheral(peripheral: CBPeripheral) -> BTPeripheralAPIType?
}