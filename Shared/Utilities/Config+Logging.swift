//
//  Config+Logging.swift
//  PowerDot-Athlete
//
//  Created by Sergey Korolkov on 23.03.16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Foundation
import XCGLogger

//MARK: Athlete app specific loggers
extension Log {
    
    ///Use to log my devices subsystem
    static let aMyDevices: XCGLogger = {
        return Log.createLoggerWithIdentifier("myDevices")
    }()
    
    ///Use to log prestimulation subsystem
    static let aPrestimulation: XCGLogger = {
        return Log.createLoggerWithIdentifier("prestimulation")
    }()
    
    ///Use to log stimulation subsystem
    static let aStimulation: XCGLogger = {
        return Log.createLoggerWithIdentifier("stimulation")
    }()
}

//MARK: Setup
extension Config {
    
    static func setupLoggers() {
        let loggers = [
            Log.application,
            Log.bluetooth,
            
            Log.aMyDevices,
            Log.aPrestimulation,
            Log.aStimulation
        ]
        
        Log.setLogLevel(.Verbose, toLoggers: loggers)
    }
}