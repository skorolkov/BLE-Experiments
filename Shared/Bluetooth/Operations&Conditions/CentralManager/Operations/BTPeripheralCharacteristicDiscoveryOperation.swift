//
//  BTPeripheralCharacteristicDiscoveryOperation.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/11/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth
import Operations

struct BTCharacteristicDiscovery {
    
    typealias BTCharactericticDiscoveryType = BTDiscoveryResult<CBCharacteristic, BTError>
    
    let characteristicPrototype: BTCharacteristic
    let discoveryResult: BTCharactericticDiscoveryType
    
    init(characteristic: BTCharacteristic,
         discoveryResult: BTCharactericticDiscoveryType) {
        self.characteristicPrototype = characteristic
        self.discoveryResult = discoveryResult
    }
}

struct BTServiceDiscovery {
    
    typealias BTServiceDiscoveryResult = BTDiscoveryResult<CBService, BTError>
    
    let UUID: CBUUID
    let discoveryResult: BTServiceDiscoveryResult
    
    private(set) var characteristicDiscoveries: [BTCharacteristicDiscovery] = []
    
    init(UUID: CBUUID, discoveryResult: BTServiceDiscoveryResult) {
        self.UUID = UUID
        self.discoveryResult = discoveryResult
    }
    
    mutating func addCharacteristicDiscovery(characteristicDiscovery: BTCharacteristicDiscovery) {
        characteristicDiscoveries.append(characteristicDiscovery)
    }
}

class BTPeripheralCharacteristicDiscoveryOperation: BTPeripheralOperation {
    
    // MARK: Internal Properties
    
    private(set) var discoveredServices: [BTServiceDiscovery]? = nil
    
    // MARK: Private Properties
    
    private var servicePrototypes: [BTService]? = nil
    
    // MARK: Initializers
    
    init(centralManager: BTCentralManagerAPIType,
         peripheral: BTPeripheralAPIType,
         servicesPrototypes: [BTService]? = nil) {
        
        super.init(centralManager: centralManager,
                   peripheral: peripheral)
        
        self.servicePrototypes = servicesPrototypes
        
        addCondition(BTCentralManagerPoweredOnCondition(centralManager: centralManager))
    }
    
    override func execute() {
        guard !cancelled else { return }
        
        centralManager?.addHandler(self)
        peripheral?.addHandler(self)
        
        let serviceUUIDs = servicePrototypes?.map { $0.UUID }
        
        peripheral?.discoverServices(serviceUUIDs)
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTPeripheralCharacteristicDiscoveryOperation: BTCentralManagerHandlerProtocol {
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        
        if central.state != .PoweredOn {
            let error = BTCentralManagerStateInvalidError(withExpectedState: .PoweredOn,
                                                          realState: central.state)
            removeHandlerAndFinish(error)
        }
    }
    
    func centralManager(
        central: BTCentralManagerAPIType,
        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
                                error: NSError?) {
        
        let btError: ErrorType? = (error != nil) ?
            BTCentralManagerFailToConnectPeripheralError(originalError: error) : nil
        removeHandlerAndFinish(btError)
        
    }
}

// MARK: BTPeripheralHandlerProtocol

extension BTPeripheralCharacteristicDiscoveryOperation: BTPeripheralHandlerProtocol {
    
    func peripheral(peripheral: BTPeripheralAPIType,
                    didDiscoverServices error: NSError?) {
        
        if let originalError = error {
            let btError = BTPeriphalServiceDiscoveryError(originalError: originalError)
            removeHandlerAndFinish(btError)
            return
        }
        
        discoveredServices = BTPeripheralCharacteristicDiscoveryOperation.serviceDiscoveriesWithServices(
            peripheral.services,
            servicePrototypes: servicePrototypes)
        
        let itemsToDiscover = BTPeripheralCharacteristicDiscoveryOperation.serviceAndCharacteristicToDiscover(
            discoveredServices, servicePrototypes: servicePrototypes)
        
        guard !itemsToDiscover.isEmpty else {
            removeHandlerAndFinish()
            return
        }
        
        itemsToDiscover.forEach { (service, characteristicUUIDs) in
            peripheral.discoverCharacteristics(characteristicUUIDs, forService: service)
        }
    }
    
    func peripheral(
        peripheral: BTPeripheralAPIType,
        didDiscoverCharacteristicsForService service: CBService,
                                             error: NSError?) {
        
        
    }
}


// MARK: Private Methods

private extension BTPeripheralCharacteristicDiscoveryOperation {
    
    static func serviceDiscoveriesWithServices(
        services: [CBService]?,
        servicePrototypes: [BTService]?) -> [BTServiceDiscovery] {
        
        let serviceUUIDs = servicePrototypes?.map({ $0.UUID })
        
        guard services == nil && serviceUUIDs == nil else {
            return []
        }
        
        if let cbServices = services where serviceUUIDs == nil {
            return cbServices.map { service in
                BTServiceDiscovery(UUID: service.UUID, discoveryResult: .Success(value: service))
            }
        }
        else if let UUIDs = serviceUUIDs where services == nil {
            return UUIDs.map { UUID in
                BTServiceDiscovery(UUID: UUID, discoveryResult: .NotFound)
            }
        }
        else if let cbServices = services, let UUIDs = serviceUUIDs {
            
            return UUIDs.map { UUID in
                guard let index = cbServices.indexOf({ (s: CBService) in return s.UUID.isEqual(UUID) }) else {
                    return BTServiceDiscovery(UUID: UUID, discoveryResult: .NotFound)
                }
                
                return BTServiceDiscovery(UUID: UUID, discoveryResult: .Success(value: cbServices[index]))
            }
        }
        
        return []
    }
    
    static func serviceAndCharacteristicToDiscover(serviceDiscoveries: [BTServiceDiscovery]?,
                                                   servicePrototypes: [BTService]?)
        -> [(CBService, [CBUUID]?)] {
            
            guard let discoveries = serviceDiscoveries else {
                return []
            }
            
            let services = discoveries.flatMap { (discovery: BTServiceDiscovery) -> CBService?  in
                if case .Success(let value) = discovery.discoveryResult {
                    return value
                }
                else {
                    return nil
                }
            }
            
            if let prototypes = servicePrototypes {
                return prototypes.flatMap { (prototype: BTService) -> (CBService, [CBUUID]?)? in
                    guard let index = services.indexOf({ (s: CBService) in return s.UUID.isEqual(prototype.UUID) }) else {
                        return nil
                    }
                    
                    return (services[index], prototype.characteristics.map({ $0.UUID }) )
                }
            }
            else {
                return services.map { service in return (service, nil) }
            }
    }
}
