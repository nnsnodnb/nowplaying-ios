//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import APIKit
import Crashlytics
import Fabric
import FirebaseCore
import FirebaseAnalytics
import GoogleMobileAds
import KeychainAccess
import RxSwift
import SVProgressHUD
import TwitterKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let keychain = Keychain()
    private let disposeBag = DisposeBag()

    private var backgroundTaskID: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        SVProgressHUD.setDefaultMaskType(.black)
        loadEnvironment()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = PlayViewController()

        TWTRTwitter.sharedInstance().start(withConsumerKey: ProcessInfo.processInfo.get(forKey: .twitterConsumerKey),
                                           consumerSecret: ProcessInfo.processInfo.get(forKey: .twitterConsumerSecret))
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
//        keychain.remove(KeychainKey.mastodonClientID.rawValue)
//        keychain.remove(KeychainKey.mastodonClientSecret.rawValue)
//        keychain.remove(KeychainKey.mastodonAccessToken.rawValue)
        #endif

        if UserDefaults.string(forKey: .tweetFormat) == nil {
            UserDefaults.set(defaultPostFormat, forKey: .tweetFormat)
        }
        if UserDefaults.string(forKey: .tweetWithImageType) == nil {
            UserDefaults.set(WithImageType.onlyArtwork.rawValue, forKey: .tweetWithImageType)
        }
        if UserDefaults.string(forKey: .tootFormat) == nil {
            UserDefaults.set(defaultPostFormat, forKey: .tootFormat)
        }
        if UserDefaults.string(forKey: .tootWithImageType) == nil {
            UserDefaults.set(WithImageType.onlyArtwork.rawValue, forKey: .tootWithImageType)
        }
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]=[:]) -> Bool {
        if let source = options[.sourceApplication] as? String, source == "com.apple.SafariViewService" {
            guard let scheme = url.scheme, scheme.starts(with: "twitterkit-") else { return true }
            return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
        } else {
            return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        beginBackgroundTask(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: backgroundTaskID.rawValue))
        backgroundTaskID = UIBackgroundTaskIdentifier.invalid
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

    private func beginBackgroundTask(_ application: UIApplication) {
        let name = "AutoTweetBackgroundTask_\(UUID().uuidString)"
        backgroundTaskID = application.beginBackgroundTask(withName: name) { [weak self] in
            guard let wself = self else { return }
            application.endBackgroundTask(.init(rawValue: wself.backgroundTaskID.rawValue))
            wself.backgroundTaskID = .invalid
        }
    }

    private func loadEnvironment() {
        guard let path = Bundle.main.path(forResource: R.file.env) else {
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
        Session.shared.rx.response(AppInfoRequest())
            .subscribe(onSuccess: { [weak self] (response) in
                let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
                if current.compare(response.appVersion.require, options: .numeric) == .orderedAscending {
                    // 必須アップデート
                    let alert = UIAlertController(title: "アップデートが必要です", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "AppStoreを開く", style: .default) { (_) in
                        UIApplication.shared.open(URL(string: websiteURL)!, options: [:], completionHandler: nil)
                    })
                    alert.preferredAction = alert.actions.first
                    DispatchQueue.main.async {
                        self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                } else if current.compare(response.appVersion.latest, options: .numeric) == .orderedAscending {
                    // アップデートあり
                    let alert = UIAlertController(title: "アップデートがあります", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "あとで", style: .cancel, handler: nil))
                    let action = UIAlertAction(title: "AppStoreを開く", style: .default) { (_) in
                        let url = URL(string: websiteURL)!
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    alert.addAction(action)
                    alert.preferredAction = action
                    DispatchQueue.main.async {
                        self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
