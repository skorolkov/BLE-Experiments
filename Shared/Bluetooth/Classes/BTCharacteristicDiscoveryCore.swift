//
//  BTCharacteristicDiscoveryCore.swift
//  BLE-Central-OSX
//
//  Created by d503 on 5/29/16.
//  Copyright © 2016 d503. All rights reserved.
//

import CoreBluetooth

private struct BTServiceCharacteristicDiscovery {
    
    enum BTDiscoveryStatus {
        case Finished(error: NSError?)
        case Waiting
    }
    
    let UUID: CBUUID
    private (set) var discoveryStatus: BTDiscoveryStatus
    
    init(UUID: CBUUID, discoveryStatus: BTDiscoveryStatus) {
        self.UUID = UUID
        self.discoveryStatus = discoveryStatus
    }
    
    mutating func updateStatus(status: BTDiscoveryStatus) {
        discoveryStatus = status
    }
}

private func ==(left: BTServiceCharacteristicDiscovery.BTDiscoveryStatus,
                right: BTServiceCharacteristicDiscovery.BTDiscoveryStatus) -> Bool {
    switch (left, right) {
    case (.Finished(let leftError), .Finished(let rightError)):
        if leftError == nil && rightError == nil {
            return true
        }
        else if let le = leftError, re = rightError {
            return le.isEqual(re)
        }
        else {
            return false
        }
    case (.Waiting, .Waiting):
        return true
    default:
        return false
    }
}

class BTCharacteristicDiscoveryCore {
    
    // MARK: Internal Properties
    
    var serviceUUIDs: [CBUUID]? {
        return servicePrototypes.isEmpty ? nil : servicePrototypes.map { $0.UUID }
    }
    
    // MARK: Private Properties
    
    private var servicePrototypes: [BTServicePrototype]
    
    private var serviceDiscoveries: [BTServiceCharacteristicDiscovery] = []
    
    // MARK: Initializers
    
    init(servicePrototypes: [BTServicePrototype] = []) {
        self.servicePrototypes = servicePrototypes
    }
    
    // MARK: Internal API
    
    func discoveredServices(services: [CBService]) -> [(CBService, [CBUUID]?)] {
        
        guard !services.isEmpty else {
            return []
        }
        
        var itemsToDiscover: [(CBService, [CBUUID]?)] = []
        
        if servicePrototypes.isEmpty {
            itemsToDiscover = services.map { service in
                return (service, nil)
            }
        }
        else {
            
            itemsToDiscover = servicePrototypes.flatMap {
                (prototype: BTServicePrototype) -> (CBService, [CBUUID]?)? in
                
                guard let index = services.indexOf({ (s: CBService) in return s.UUID.isEqual(prototype.UUID) }) else {
                    return nil
                }
                
                let characteristicUUIDS: [CBUUID]? = prototype.characteristicPrototypes.isEmpty ? nil :
                    prototype.characteristicPrototypes.map({ $0.UUID })
                
                return (services[index], characteristicUUIDS)
            }
        }
        
        self.serviceDiscoveries = itemsToDiscover.map { (service, _) in
            return BTServiceCharacteristicDiscovery(UUID: service.UUID, discoveryStatus: .Waiting)
        }
        
        return itemsToDiscover
    }
    
    func discoveredCharacteristicsForService(service: CBService, error: NSError?) -> Bool {
        
        guard let index = serviceDiscoveries.indexOf({ return $0.UUID.isEqual(service.UUID) }) else {
            // we don't interested in this service's characteristics
            
            return isDiscoveryFinished()
        }
        
        if let discoveryError = error {
            serviceDiscoveries[index].updateStatus(.Finished(error: discoveryError))
            
            return isDiscoveryFinished()
        }
        
        serviceDiscoveries[index].updateStatus(.Finished(error: nil))
        
        return isDiscoveryFinished()
    }
    
    func isDiscoveryFinished() -> Bool {
        for service in serviceDiscoveries {
            if service.discoveryStatus == .Waiting {
                return false
            }
        }
        
        return true
    }
}
 