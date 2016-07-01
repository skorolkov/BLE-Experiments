//
//  MainController.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Cocoa
import CoreBluetooth
import ReactiveCocoa

class MainController: NSViewController {
    
    // MARK: Private Properties
    @IBOutlet weak var startScanButton: NSButton!
    @IBOutlet weak var stopScanButton: NSButton!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var disconnectButton: NSButton!
    @IBOutlet weak var discoverButton: NSButton!
    @IBOutlet weak var enableNotificationsButton: NSButton!
    
    private var centralRolePerformer = BTCentralRolePerformer.sharedInstance
    
    private var peripheralDataProvider: BTPeripheralProviding =
        BTCentralRolePerformer.sharedInstance.peripheralDataProvider
    
    
    private var scanSignalProvider: BTPeripheralScanSignalProvider?  = nil
    private var scanSignalProviderDisposable: Disposable? = nil
    
    private var connectSignalProvider: BTPeripheralConnectSignalProvider? = nil
    private var disconnectSignalProvider: BTPeripheralDisconnectSignalProvider? = nil
    
    private var characteristicDiscoverySignalProvider: BTPeripheralCharacteristicDiscoverySignalProvider? = nil
    
    private var peripheralModels: [BTPeripheral] = []
    
    private var scannedPeripheralModels: [BTPeripheral] {
        return filterdPeripheralModelsWithState(.Scanned(advertisementData: [:], RSSI: 0))
    }
    
    private var connectedPeripheralModels: [BTPeripheral] {
        return filterdPeripheralModelsWithState(.Connected)
    }
    
    private var disconnectedPeripheralModels: [BTPeripheral] {
        return filterdPeripheralModelsWithState(.Disconnected(error: nil))
    }
    
    private var discoveredCharacteristicdPeripheralModels: [BTPeripheral] {
        return filterdPeripheralModelsWithState(.CharacteristicDiscovered)
    }
    
    // MARK: Lifecycle
    
    deinit {
        scanSignalProviderDisposable?.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startScanButton.enabled = true
        stopScanButton.enabled = false
        connectButton.enabled = false
        disconnectButton.enabled = false
        discoverButton.enabled = false
        
        peripheralDataProvider.peripherals
            .producer
            .observeOn(UIScheduler())
            //.skipRepeats({ $0 != $1 })
            .on(next: { peripheralModels in
                self.peripheralModels = peripheralModels
                Log.application.info("peripheral models updated: \(peripheralModels)")
                
                self.connectButton.enabled = (self.scannedPeripheralModels.count > 0) ||
                    (self.disconnectedPeripheralModels.count > 0)
                self.disconnectButton.enabled = (self.connectedPeripheralModels.count > 0) ||
                    (self.discoveredCharacteristicdPeripheralModels.count > 0)
                self.discoverButton.enabled = (self.connectedPeripheralModels.count > 0)
            })
            .start()
    }
}

// MARK: Actions

private extension MainController {
    @IBAction func startScanningButtonPressed(sender: NSButton) {
        
        scanSignalProvider = centralRolePerformer.scanSignalProvider(
            withServices: [CBUUID(string: "C14D2C0A-401F-B7A9-841F-E2E93B80F631")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey : false],
            timeout: 600,
            stopScanningCondition: { discoveryResults -> Bool in
                discoveryResults.count == 2
        })
        
        scanSignalProviderDisposable = scanSignalProvider?.scan().producer
            .observeOn(UIScheduler())
            .skipRepeats({ $0 != $1 })
            .on(started: {
                self.startScanButton.enabled = false
                self.stopScanButton.enabled = true
            })
            .on(next: { peripherals in
                Log.application.info("scanning: found peripherals: \(peripherals)")
            })
            .on(event: { event in
                switch event {
                case .Completed, .Failed(_), .Interrupted:
                    self.startScanButton.enabled = true
                    self.stopScanButton.enabled = false
                default:
                    break
                }
            })
            .start()
    }
    
    @IBAction func stopScanningButtonPressed(sender: NSButton) {
        scanSignalProvider?.stopScan()
        
        if let disposable = scanSignalProviderDisposable where !disposable.disposed {
            scanSignalProviderDisposable?.dispose()
            scanSignalProviderDisposable = nil
        }
    }
    
    @IBAction func connectButtonPressed(sender: NSButton) {
        
        var indentifierString = scannedPeripheralModels.first?.identifierString
        
        if indentifierString == nil {
            indentifierString = disconnectedPeripheralModels.first?.identifierString
        }
        
        guard let indentifier = indentifierString else {
            return
        }
        
        guard let peripheral = centralRolePerformer.peripheralWithIdentifier(indentifier) else {
            return
        }
        
        connectSignalProvider = centralRolePerformer.connectSignalProviderWithPeripheral(peripheral)
        
        connectSignalProvider?.connect().producer
            .observeOn(UIScheduler())
            .on(next: { peripherals in
                Log.application.info("connecting: connected peripherals: \(peripherals)")
            })
            .start()
    }
    
    @IBAction func disconnectButtonPressed(sender: NSButton) {
        
        guard let indentifierString = connectedPeripheralModels.first?.identifierString else {
            return
        }
        
        guard let peripheral = centralRolePerformer.peripheralWithIdentifier(indentifierString) else {
            return
        }
        
        disconnectSignalProvider = centralRolePerformer.disconnectSignalProviderWithPeripheral(peripheral)
        
        disconnectSignalProvider?.disconnect().producer
            .observeOn(UIScheduler())
            .on(next: { peripherals in
                Log.application.info("disconnecting: disconnected peripherals: \(peripherals)")
            })
            .start()
    }
    
    @IBAction func discoverButtonPressed(sender: NSButton) {
        
        guard let indentifierString = connectedPeripheralModels.first?.identifierString else {
            return
        }
        
        guard let peripheral = centralRolePerformer.peripheralWithIdentifier(indentifierString) else {
            return
        }
        
        characteristicDiscoverySignalProvider = centralRolePerformer.discoverCharacteristicsSignalProviderWithPeripheral(
            peripheral,
            servicePrototypes: [])
        
        
        characteristicDiscoverySignalProvider?.discover().producer
            .observeOn(UIScheduler())
            .on(next: { peripherals in
                Log.application.info("characteristic discovery: peripherals: \(peripherals)")
            })
            .start()
    }
    
    @IBAction func enableNotificationsButtonPressed(sender: NSButton) {
        guard let indentifierString = discoveredCharacteristicdPeripheralModels.first?.identifierString else {
            return
        }
        
        guard let peripheral = centralRolePerformer.peripheralWithIdentifier(indentifierString) else {
            return
        }
    }
}

// MARK: Suppotring Methods

private extension MainController {
    func filterdPeripheralModelsWithState(state: BTPeripheralState) -> [BTPeripheral] {
        return peripheralModels.filter({
            switch ($0.state, state) {
            case (.Disconnected(_), .Disconnected(_)),
            (.Connected, .Connected),
            (.CharacteristicDiscovered, .CharacteristicDiscovered):
                return true
            case (.Scanned(_, _), .Scanned(_, _)):
                return true
            default:
                return false
            }
        })
    }
}
