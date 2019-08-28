//
//  AppDelegate.swift
//  Miagi-Reminder
//
//  Created by apple on 8/12/19.
//  Copyright © 2019 apple. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyBuLpjDqcqLnAcpI8wqL56l6Ytj6z0PpG4")
        GMSPlacesClient.provideAPIKey("AIzaSyBuLpjDqcqLnAcpI8wqL56l6Ytj6z0PpG4")
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "SwitchState") != nil {
            //            addEvent.switch1.isOn = defaults.bool(forKey: "SwitchState")
            print("ON")
        }
        if defaults.object(forKey: "SwitchStates") != nil {
            print("ON")
        }
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.requestAuthorization(options: options) {
            (granted, error) in
            if granted {
                print("granted")
            } else {
                print("declined")
            }
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
}
