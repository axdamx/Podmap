//
//  AppDelegate.swift
//  Podmap
//
//  Created by Mohd Adam on 23/08/2018.
//  Copyright © 2018 Mohd Adam. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let apikey = "AIzaSyBmK4Z9YdzzOSG7Xi70zCbkbJt1hJIa-ts"
    
    let AppID = "84b269e5-a089-4aab-ac06-94ed93359209"
    let AppKey = "06feddcd-d67b-47e3-b1f1-2d0d248d272b"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(apikey)
        
        let freschatConfig:FreshchatConfig = FreshchatConfig.init(appID: AppID, andAppKey: AppKey)
        freschatConfig.gallerySelectionEnabled = true; // set NO to disable picture selection for messaging via gallery
        freschatConfig.cameraCaptureEnabled = true; // set NO to disable picture selection for messaging via camera
        freschatConfig.teamMemberInfoVisible = true; // set to NO to turn off showing an team member avatar. To customize the avatar shown, use the theme file
        freschatConfig.showNotificationBanner = true; // set to NO if you don't want to show the in-app notification banner upon receiving a new message while the app is open
    
        
        Freshchat.sharedInstance().initWith(freschatConfig)
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
        var freahchatUnreadCount = Int()
        Freshchat.sharedInstance().unreadCount { (unreadCount) in
            freahchatUnreadCount = unreadCount
        }
        UIApplication.shared.applicationIconBadgeNumber = freahchatUnreadCount;
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Freshchat.sharedInstance().setPushRegistrationToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if Freshchat.sharedInstance().isFreshchatNotification(userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(userInfo, andAppstate: application.applicationState)
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent: UNNotification,
                                withCompletionHandler: @escaping (UNNotificationPresentationOptions)->()) {
        if Freshchat.sharedInstance().isFreshchatNotification(willPresent.request.content.userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(willPresent.request.content.userInfo, andAppstate: UIApplication.shared.applicationState)  //Handled for freshchat notifications
        } else {
            withCompletionHandler([.alert, .sound, .badge]) //For other notifications
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive: UNNotificationResponse,
                                withCompletionHandler: @escaping ()->()) {
        if Freshchat.sharedInstance().isFreshchatNotification(didReceive.notification.request.content.userInfo) {
            Freshchat.sharedInstance().handleRemoteNotification(didReceive.notification.request.content.userInfo, andAppstate: UIApplication.shared.applicationState) //Handled for freshchat notifications
        } else {
            withCompletionHandler() //For other notifications
        }
    }


}

