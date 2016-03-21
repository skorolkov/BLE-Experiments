//
//  PeriphralFullAPIProtocol.swift
//  BLE-Experiments
//
//  Created by d503 on 3/11/16.
//
//

import CoreBluetooth

@objc protocol PeriphralFullAPIProtocol: BTPeripheralAPIProtocol {
    
    weak var delegate: CBPeripheralDelegate? { get set }
}

extension CBPeripheral: PeriphralFullAPIProtocol {}
