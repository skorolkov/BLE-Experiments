//
//  Log.swift
//  PowerDot-Athlete
//
//  Created by Sergey Korolkov on 23.03.16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Foundation
import XCGLogger

struct LogDestination: OptionSetType {
    let rawValue: Int
    init(rawValue: Int) { self.rawValue = rawValue }
    
    static let DebugConsole = LogDestination(rawValue: 1 << 1)
    static let SystemConsole = LogDestination(rawValue: DebugConsole.rawValue | 1 << 2)
}

class Log {
    static let application: XCGLogger = {
        return Log.createLoggerWithIdentifier("application")
    }()
    
    static let bluetooth: XCGLogger = {
        return Log.createLoggerWithIdentifier("bluetooth")
    }()
}

extension Log {
    
    ///Creates logger with .None output level
    static func createLoggerWithIdentifier(identifier: String, destinations: LogDestination = [.SystemConsole]) -> XCGLogger {
        let log = XCGLogger(identifier: identifier, includeDefaultDestinations: false)
        
        
        if destinations.contains(.SystemConsole) {
            let destination = XCGNSLogDestination(owner: log)
            destination.configureForApplication()
            log.addLogDestination(destination)
        }
        else if destinations.contains(.DebugConsole) {
            let destination = XCGConsoleLogDestination(owner: log)
            destination.configureForApplication()
            log.addLogDestination(destination)
        }
        
        log.outputLogLevel = .None
        
        return log
    }
    
    static func setLogLevel(level: XCGLogger.LogLevel, toLoggers loggers: [XCGLogger]) {
        for logger in loggers {
            logger.outputLogLevel = level
        }
    }
}

private extension XCGBaseLogDestination {
    func configureForApplication() {
        showLogIdentifier = true
        showFunctionName = false
        showThreadName = false
        showFileName = false
        showLineNumber = false
        showLogLevel = true
        showDate = true
    }
}

