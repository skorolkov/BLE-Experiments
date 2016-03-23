//
//  AppDelegate.swift
//  BLE-Central-OSX
//
//  Created by d503 on 3/21/16.
//  Copyright © 2016 d503. All rights reserved.
//

import Cocoa
import CocoaLumberjack

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        configureLoggingStuff()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func configureLoggingStuff() {
        // your log statements will be sent to the Console.app and
        // the Xcode console (just like a normal NSLog)
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
            
        let formatter = CustomLogFormatter()
            
        DDTTYLogger.sharedInstance().logFormatter = formatter
        
        defaultDebugLevel = Config.ddLogLevel
        
        DDLogInfo("\n\n\n\t\t\t\t\t\t***** Application started *****\n\n\n")
    }

}

