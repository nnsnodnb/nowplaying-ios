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
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let keychain = Keychain()

    private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SVProgressHUD.setDefaultMaskType(.clear)
        loadEnvironment()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = PlayViewController()

        TWTRTwitter.sharedInstance().start(withConsumerKey: ProcessInfo.processInfo.get(forKey: .twitterConsumerKey),
                                           consumerSecret: ProcessInfo.processInfo.get(forKey: .twitterConsumerSecret))
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        GADMobileAds.configure(withApplicationID: ProcessInfo.processInfo.get(forKey: .firebaseAdmobAppId))
//        PaymentManager.shared.startTransactionObserve()
        #if DEBUG
        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(false)
//        keychain.remove(KeychainKey.mastodonClientID.rawValue)
//        keychain.remove(KeychainKey.mastodonClientSecret.rawValue)
//        keychain.remove(KeychainKey.mastodonAccessToken.rawValue)
        #endif
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]=[:]) -> Bool {
        if let sourceApplication = options[.sourceApplication] as? String {
            if String(describing: sourceApplication) == "com.apple.SafariViewService" {
                NotificationCenter.default.post(name: .receiveSafariNotificationName, object: url)
                return true
            }
        }
        return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        backgroundTaskID = application.beginBackgroundTask(withName: "AutoTweetBackgroundTask") { [weak self] in
            guard let wself = self else { return }
            application.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: wself.backgroundTaskID.rawValue))
            wself.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: backgroundTaskID.rawValue))
        resignFirstResponder()
        checkFirebaseHostingAppVersion()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        application.endReceivingRemoteControlEvents()
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print(userActivity.webpageURL!)
        }
        return true
    }

    private func loadEnvironment() {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil) else {
            fatalError("Not found: 'Resources/.env'.\nPlease create .env file reference from .env.sample")
        }
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let str = String(data: data, encoding: .utf8) ?? "Empty File"
            let clean = str.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "")
            let envVars = clean.components(separatedBy: "\n")
            for envVar in envVars {
                let keyVal = envVar.components(separatedBy: "=")
                if keyVal.count == 2 {
                    setenv(keyVal[0], keyVal[1], 1)
                }
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func checkFirebaseHostingAppVersion() {
        AppInfoManager().fetch { [weak self] (result) in
            guard let wself = self else { return }
            switch result {
            case .success(let response):
                guard let body = response.body, let appVersion = body["app_version"] as? Parameters,
                    let requireVerion = appVersion["require"] as? String, let latestVersion = appVersion["latest"] as? String else {
                        return
                }
                let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

                if current.compare(requireVerion, options: .numeric) == .orderedAscending {
                    // 必須アップデート
                    let alert = UIAlertController(title: "アップデートが必要です", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "AppStoreを開く", style: .cancel) { (_) in
                        let url = URL(string: websiteUrl)!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    })
                    DispatchQueue.main.async {
                        wself.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                } else if current.compare(latestVersion, options: .numeric) == .orderedAscending {
                    // アップデートがある
                    let alert = UIAlertController(title: "アップデートがあります", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "あとで", style: .cancel, handler: nil))
                    let action = UIAlertAction(title: "AppStoreを開く", style: .cancel) { (_) in
                        let url = URL(string: websiteUrl)!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    alert.addAction(action)
                    alert.preferredAction = action
                    DispatchQueue.main.async {
                        wself.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            case .failure:
                break
            }
        }
    }
}
