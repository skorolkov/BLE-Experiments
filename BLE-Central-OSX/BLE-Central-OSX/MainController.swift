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
    
    private let kPeripheralName = "MyAwesomePeripheral"
    
    // MARK: IBActions
    @IBOutlet weak var startScanButton: NSButton!
    @IBOutlet weak var stopScanButton: NSButton!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var disconnectButton: NSButton!
    @IBOutlet weak var discoverButton: NSButton!
    @IBOutlet weak var enableNotificationsButton: NSButton!
    
    // MARK: Private Properties
    
    private var centralRolePerformer = BTCentralRolePerformer.sharedInstance
    
    private var peripheralDataProvider: BTPeripheralProviding =
        BTCentralRolePerformer.sharedInstance.peripheralDataProvider
    
    private var scanSignalProvider: BTPeripheralScanSignalProvider?  = nil
    private var scanSignalProviderDisposable: Disposable? = nil
    
    private var connectSignalProvider: BTPeripheralConnectSignalProvider? = nil
    private var disconnectSignalProvider: BTPeripheralDisconnectSignalProvider? = nil
    
    private var characteristicDiscoverySignalProvider: BTPeripheralCharacteristicDiscoverySignalProvider? = nil
    
    private var setNotifyValueSignalProvider: BTCharacteristicSetNotifyValueSignalProvider? = nil

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
            options: [CBCentralManagerScanOptionAllowDuplicatesKey : false],
            timeout: 600,
            validatePeripheralPredicate: {
                if let name = $0.peripheral.name {
                    return name == self.kPeripheralName
                }
                else {
                    return true
                }
            },
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
        
        var indentifierString = filterPeripheralModels(scannedPeripheralModels,
                                                       withName: kPeripheralName).first?.identifierString
        
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
        
        guard let indentifierString = filterPeripheralModels(connectedPeripheralModels,
                                                             withName: kPeripheralName).first?.identifierString else {
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
        
        guard let indentifierString = filterPeripheralModels(connectedPeripheralModels,
                                                             withName: kPeripheralName).first?.identifierString else {
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
        
        guard let indentifierString =  filterPeripheralModels(discoveredCharacteristicdPeripheralModels,
                                                              withName: kPeripheralName).first?.identifierString else {
            return
        }
        
        guard let peripheral = centralRolePerformer.peripheralWithIdentifier(indentifierString) else {
            return
        }
        
        guard let characteristic = peripheral.characteristicWithUUIDString(
            "295CEA7E-78E8-4B4E-9870-6F30CED85075", properties: .Read) else {
            return
        }
        
        setNotifyValueSignalProvider = centralRolePerformer.notificationsEnabledValueUpdateSignalProvider(
            true,
            peripheral: peripheral,
            characteristic: characteristic)
        
        setNotifyValueSignalProvider?.setNotifyValue().producer
            .observeOn(UIScheduler())
            .on(next: { peripheral in
                Log.application.info("characteristic notify value updated: " +
                    "peripherals id =\(peripheral?.identifierString)" +
                    "characteristic: \(peripheral?.characteristics)")
            })
            .start()
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
    
    func filterPeripheralModels(peripheralModels: [BTPeripheral], withName name: String) -> [BTPeripheral] {
        return peripheralModels.filter({
            if let peripheralName = $0.name {
                return peripheralName == name
            }
            
            return false
        })
    }
}
