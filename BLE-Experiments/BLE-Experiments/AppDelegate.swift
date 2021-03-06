//
//  AppDelegate.swift
//  BLE-Experiments
//
//  Created by d503 on 3/7/16.
//
//

import UIKit
import CocoaLumberjack

#if FLEX_ENABLED
    import FLEX
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
        
        self.configureLoggingStuff()
        
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
        // FIXME: replace this line with corrent controller
        self.window?.rootViewController = UIViewController();
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    #if FLEX_ENABLED
    
    // MARK: - Methods overriden for FLEX
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if (motion == UIEventSubtype.MotionShake) {
            if (FLEXManager.sharedManager().isHidden) {
                FLEXManager.sharedManager().showExplorer()
            }
        }
        else {
            FLEXManager.sharedManager().hideExplorer()
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    #endif
}

// MARK: Logging Support

private extension AppDelegate {
    func configureLoggingStuff() {
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

