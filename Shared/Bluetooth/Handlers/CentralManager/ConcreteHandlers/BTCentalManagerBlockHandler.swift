//
//  CentalManagerBlockHandler.swift
//  BLE-Experiments
//
//  Created by d503 on 3/8/16.
//
//

import Foundation

/**
 * Some methods of BTCentralManagerHandlerProtocol are optional, so class should be declared as @objc class,
 * and (as required by usage of '@objc' directive) it must inherit NSObject class
 */

@objc class BTCentalManagerBlockHandler: BTCustomQueueHandler {
    
    // MARK: Typenames
    
    typealias BTCentralUpdateStateBlock = (central: BTCentralManagerAPIType) -> Void
    
    typealias BTCentalRestoreStateBlock = (central: BTCentralManagerAPIType,
        willRestoreStateWithDict: [String : AnyObject]) -> Void
    
    typealias BTPeripheralConnectBlock = (central: BTCentralManagerAPIType,
        peripheral: BTPeripheralAPIType) -> Void
    
    typealias BTPeripheraDisconnectOrFailBlock = (central: BTCentralManagerAPIType,
        peripheral: BTPeripheralAPIType,
        error: NSError?) -> Void
    
    typealias BTDiscoverPeripheralBlock = (central: BTCentralManagerAPIType,
        discoveredPeripheral: BTPeripheralAPIType,
        advertisementData: [String : AnyObject],
        RSSI: NSNumber) -> Void
    
    // MARK: Internal Properties
    
    var didUpdateStateBlock: BTCentralUpdateStateBlock
    var willRestoreStateBlock: BTCentalRestoreStateBlock? = nil
    var didConnectPeripheralBlock: BTPeripheralConnectBlock? = nil
    var didDisconnectPeripheralBlock: BTPeripheraDisconnectOrFailBlock? = nil
    var failToConnectToPeripheralBlock: BTPeripheraDisconnectOrFailBlock? = nil
    var didDiscoverPeripheralBlock: BTDiscoverPeripheralBlock? = nil
    
    // MARK: Initializers
    
    init(withDidUpdateStateBlock didUpdateStateBlock: BTCentralUpdateStateBlock) {
        self.didUpdateStateBlock = didUpdateStateBlock
        super.init()
    }

    init(withDidUpdateStateBlock didUpdateStateBlock: BTCentralUpdateStateBlock,
        handlerQueue: dispatch_queue_t) {
            self.didUpdateStateBlock = didUpdateStateBlock
            super.init(withHandlerQueue: handlerQueue)
    }
    
    override init(withHandlerQueue queue: dispatch_queue_t) {
        self.didUpdateStateBlock = { _ in }
        super.init(withHandlerQueue: queue)
    }
    
    override init() {
        self.didUpdateStateBlock = { _ in }
        super.init()
    }
}

// MARK: BTCentralManagerHandlerProtocol

extension BTCentalManagerBlockHandler: BTCentralManagerHandlerProtocol {
    // MARK: Monitoring Changes to the Central Manager’s State
    
    func centralManagerDidUpdateState(central: BTCentralManagerAPIType) {
        dispatch_async(queue) { [unowned self] () -> Void in
            self.didUpdateStateBlock(central: central)
        }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
        willRestoreState dict: [String : AnyObject]) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.willRestoreStateBlock?(central: central, willRestoreStateWithDict: dict)
            }
    }
    
    // MARK: Monitoring Connections with Peripherals
    
    func centralManager(central: BTCentralManagerAPIType,
        didConnectPeripheral peripheral: BTPeripheralAPIType) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didConnectPeripheralBlock?(central: central, peripheral: peripheral)
            }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
        didDisconnectPeripheral peripheral: BTPeripheralAPIType,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didDisconnectPeripheralBlock?(central: central, peripheral: peripheral, error: error)
            }
    }
    
    func centralManager(central: BTCentralManagerAPIType,
        didFailToConnectPeripheral peripheral: BTPeripheralAPIType,
        error: NSError?) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.failToConnectToPeripheralBlock?(central: central, peripheral: peripheral, error: error)
            }
    }
    
    // MARK: Discovering and Retrieving Peripherals
    
    func centralManager(central: BTCentralManagerAPIType,
        didDiscoverPeripheral peripheral: BTPeripheralAPIType,
        advertisementData: [String : AnyObject],
        RSSI: NSNumber) {
            dispatch_async(queue) { [unowned self] () -> Void in
                self.didDiscoverPeripheralBlock?(central: central,
                    discoveredPeripheral: peripheral,
                    advertisementData: advertisementData,
                    RSSI: RSSI)
            }
    }
}