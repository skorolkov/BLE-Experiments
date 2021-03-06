//
//  AppDelegate.swift
//  BLE-Central-OSX
//
//  Created by d503 on 3/21/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    private var mainController: MainController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        Config.setupLoggers()
        logApplicationStart()
        
        mainController = MainController(nibName: "MainController", bundle: nil)
        
        window.contentView!.addSubview(mainController.view)
        mainController.view.frame = window.contentView!.bounds
        
        mainController.view.translatesAutoresizingMaskIntoConstraints = false
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[subView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["subView" : mainController.view])
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[subView]|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["subView" : mainController.view])
        
        NSLayoutConstraint.activateConstraints(verticalConstraints + horizontalConstraints)
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

// MARK: Logging Support

private extension AppDelegate {
    func logApplicationStart() {
        Log.application.info("\n\n\n\t\t\t\t\t\t***** Application started *****\n\n\n")
    }
}

