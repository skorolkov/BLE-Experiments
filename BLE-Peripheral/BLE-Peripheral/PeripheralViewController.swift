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
    
    private var peripheralRole = BTPeripheralRolePerformer()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: Actions

extension PeripheralViewController {
    
    @IBAction func addServiceButtonPressed(sender: UIButton) {
    }
}