//
//  Config+Logging.swift
//  PowerDot-Athlete
//
//  Created by Sergey Korolkov on 23.03.16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Foundation
import CocoaLumberjack
import XCGLogger

//MARK: XCGLogger Setup
extension Config {
    
    static func setupLoggers() {
        let loggers = [
            Log.application,
            Log.bluetooth,
        ]
        
        Log.setLogLevel(.Verbose, toLoggers: loggers)
    }
}

//MARK: CocoaLumberjack Setup
extension Config {
    static let ddLogLevel = { DDLogLevel.Verbose }()
    
    static func configureLoggingStuff() {
        // your log statements will be sent to the Console.app and
        // the Xcode console (just like a normal NSLog)
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        let formatter = CustomLogFormatter();
        
        DDTTYLogger.sharedInstance().logFormatter = formatter;
        
        defaultDebugLevel = Config.ddLogLevel
        
        DDLogInfo("\n\n\n\t\t\t\t\t\t***** Application started *****\n\n\n");
        
        let infoString = String(format: "Device:\n\tname = %@\n\tmodel = %@\n\tsystemVersion = %@\n\n",
                                UIDevice.currentDevice().name,
                                UIDevice.currentDevice().model,
                                UIDevice.currentDevice().systemVersion)
        DDLogInfo(infoString)
    }
}