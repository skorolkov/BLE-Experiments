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
    
    private var centralRolePerformer = BTCentralRolePerformer()
    private var peripheralModels: [BTPeripheral] = []
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startScanButton.enabled = true
        stopScanButton.enabled = false
        connectButton.enabled = false
        disconnectButton.enabled = false
    }
}

private extension MainController {
    @IBAction func startScanningButtonPressed(sender: NSButton) {
        centralRolePerformer.scan(
            withServices: [CBUUID(string: "C14D2C0A-401F-B7A9-841F-E2E93B80F631")],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey : false],
            timeout: 600)
        { discoveredPeripherals -> Bool in discoveredPeripherals.count == 2 }
            .producer
            .observeOn(UIScheduler())
            .skipRepeats({ $0 != $1 })
            .on(started: {
                self.startScanButton.enabled = false
                self.stopScanButton.enabled = true
            })
            .on(next: { peripherals in
                self.peripheralModels = peripherals
                Log.application.info("scanning: found peripherals: \(peripherals)")
                
                self.connectButton.enabled = (peripherals.count > 0)
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
        centralRolePerformer.stopScan()
    }
    
    @IBAction func connectButtonPressed(sender: NSButton) {
        guard let indentifierString = peripheralModels.first?.identifierString else {
            return
        }
        
        guard let peripheral = centralRolePerformer.peripheralWithIdentifier(indentifierString) else {
            return
        }
        
        let connectSignalProvider = centralRolePerformer.connectSignalProviderWithPeripheral(peripheral)
        
        connectSignalProvider.connect().producer
            .observeOn(UIScheduler())
            .on(next: { peripherals in
                self.peripheralModels = peripherals
                Log.application.info("connecting: connected peripherals: \(peripherals)")
            })
            .start()
    }
    
    @IBAction func disconnectButtonPressed(sender: NSButton) {
    }
}
