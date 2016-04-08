//
//  MainController.swift
//  BLE-Central-OSX
//
//  Created by d503 on 4/7/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Cocoa

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
        centralRolePerformer.startScanningWithCompletion(nil)
    }
}
