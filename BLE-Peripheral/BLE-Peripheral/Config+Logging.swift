//
//  Config+Logging.swift
//  PowerDot-Athlete
//
//  Created by Sergey Korolkov on 23.03.16.
//  Copyright © 2016 Polecat. All rights reserved.
//

import Foundation
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
