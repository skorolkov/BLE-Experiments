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
    
    private var centralRolePerformer = BTCentralRolePerformer()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            .on(next: { peripherals in
                Log.application.info("scanning: found peripherals: \(peripherals)")
            })
            .start()
    }
}
