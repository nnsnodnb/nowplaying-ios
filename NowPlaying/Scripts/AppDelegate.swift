//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import TwitterKit
import Fabric
import Crashlytics
import KeychainAccess
import FirebaseCore
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let keychain = Keychain()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        loadEnvironment()
        let env = ProcessInfo.processInfo.environment
        Twitter.sharedInstance().start(withConsumerKey: env[EnvironmentKey.twitterConsumerKey.rawValue]!,
                                       consumerSecret: env[EnvironmentKey.twitterConsumerSecret.rawValue]!)
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: env[EnvironmentKey.firebaseAdmobAppId.rawValue]!)
        PaymentManager.shared.startTransactionObserve()
        #if DEBUG
        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(false)
//        keychain.remove(KeychainKey.mastodonClientID.rawValue)
//        keychain.remove(KeychainKey.mastodonClientSecret.rawValue)
//        keychain.remove(KeychainKey.mastodonAccessToken.rawValue)
        #endif
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]=[:]) -> Bool {
        return Twitter.sharedInstance().application(application, open: url, options: options)
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

    override func remoteControlReceived(with event: UIEvent?) {
        AudioManager.shared.remoteControlReceived(with: event)
    }

    fileprivate func loadEnvironment() {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil) else {
            fatalError("Not found: 'Resources/.env'.\nPlease create .env file reference from .env.sample")
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let str = String(data: data, encoding: .utf8) ?? "Empty File"
            let clean = str.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
            let envVars = clean.components(separatedBy:"\n")
            for envVar in envVars {
                let keyVal = envVar.components(separatedBy:"=")
                if keyVal.count == 2 {
                    setenv(keyVal[0], keyVal[1], 1)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

