//
//  AppDelegate.swift
//  WordCam
//
//  Created by 保坂篤志 on 2021/05/15.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: nil,
            deleteRealmIfMigrationNeeded: true
        )
        Realm.Configuration.defaultConfiguration = config
        // Override point for customization after application launch.
        
        IQKeyboardManager.shared.enable = true
        
        SwiftGoogleTranslate.shared.start(with: "AIzaSyDyWT-LAuZluEbWrUWzE5_yHuWr-E8Xwk4")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){
                (granted, _) in
            if granted{
                UNUserNotificationCenter.current().delegate = self
            } else {
                print("notification is not allowed")
            }
        }
        
        FirebaseApp.configure()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        
    }
 }
