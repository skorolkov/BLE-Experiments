//
//  CustomLogFormatter.swift
//  BLE-Experiments
//
//  Created by d503 on 3/7/16.
//
//

import CocoaLumberjack

class CustomLogFormatter: NSObject, DDLogFormatter {
    
    let dateFormatter: NSDateFormatter
    
    override init() {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM hh:mm:ss:SSS"
        
        super.init()
    }
    
    func formatLogMessage(logMessage: DDLogMessage!) -> String {
        
        var logLevel: String
        let logFlag: DDLogFlag = logMessage.flag

        switch (logFlag)
        {
        case DDLogFlag.Error :
            logLevel = "[ERROR]"
            break
        case DDLogFlag.Warning:
            logLevel = "[WARN] "
            break
        case DDLogFlag.Info:
            logLevel = " INFO  "
            break
        default:
            logLevel = " VERB  "
            break
        }
        
        let date = dateFormatter.stringFromDate(logMessage.timestamp)
        
        let message = logMessage.message.stringByReplacingOccurrencesOfString("\n",
            withString: "\n\t\t")
        
        return String(format: "%@ %@\t%@", logLevel, date, message)
    }
}
