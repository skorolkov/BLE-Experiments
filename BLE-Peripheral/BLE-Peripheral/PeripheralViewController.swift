//
//  PeripheralViewController.swift
//  BLE-Peripheral
//
//  Created by d503 on 3/21/16.
//  Copyright © 2016 d503. All rights reserved.
//

import UIKit

class PeripheralViewController: UIViewController {

    // MARK: Private Properties
    
    @IBOutlet weak var startAdvertisingButton: UIButton!
    @IBOutlet weak var stopAdvertisingButton: UIButton!

    
    private var peripheralRole = BTPeripheralRolePerformer()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopAdvertisingButton.enabled = false
    }
}

// MARK: Actions

extension PeripheralViewController {
    
    @IBAction func startAdvertisiongButtonPressed(sender: UIButton) {
        peripheralRole.startAdevertisingWithCompletion { [weak self] (_, result) in
            if case .Finished = result {
                self?.startAdvertisingButton.enabled = false
                self?.stopAdvertisingButton.enabled = true
            }
        }
        stopAdvertisingButton.enabled = false
    }
    
    @IBAction func stopAdvertisingButtonPressed(sender: UIButton) {
        peripheralRole.stopAdevertising()
        startAdvertisingButton.enabled = true
        stopAdvertisingButton.enabled = false
    }
}
