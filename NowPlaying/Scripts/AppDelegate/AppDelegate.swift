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
import RealmSwift
import RxSwift
import SVProgressHUD
import SwifteriOS
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let keychain = Keychain.nowPlaying
    private let disposeBag = DisposeBag()
    private let viewModel: AppDelegateViewModelType = AppDelegateViewModel()

    private var backgroundTaskID: UIBackgroundTaskIdentifier = .init(rawValue: 0)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        commonSetup()
        subscribeViewModel()
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]=[:]) -> Bool {
        Swifter.handleOpenURL(url)

        if let source = options[.sourceApplication] as? String, source == "com.apple.SafariViewService" {
            guard let scheme = url.scheme, scheme.starts(with: "twitterkit-") else { return true }
            // FIXME: URLスキーマハンドリング
//            return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
        } else {
//            return TWTRTwitter.sharedInstance().application(application, open: url, options: options)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        beginBackgroundTask(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.endBackgroundTask(UIBackgroundTaskIdentifier(rawValue: backgroundTaskID.rawValue))
        backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        resignFirstResponder()
        viewModel.inputs.checkAppVersionTrigger.onNext(())
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

    private func commonSetup() {
        FirebaseApp.configure()
        SVProgressHUD.setDefaultMaskType(.black)
        viewModel.inputs.loadEnvironmentsTrigger.onNext(())
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = PlayViewController()

//        TWTRTwitter.sharedInstance().start(withConsumerKey: ProcessInfo.processInfo.get(forKey: .twitterConsumerKey),
//                                           consumerSecret: ProcessInfo.processInfo.get(forKey: .twitterConsumerSecret))
        Fabric.with([Crashlytics.self])
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(false)
        let realmEncryptionKeyString = realmConfiguration.encryptionKey!.map { String(format: "%.2hhx", $0) }.joined()
        print("🔑 Realm encryption key: \(realmEncryptionKeyString)")
//        let realm = try! Realm(configuration: realmConfiguration)
//        try! realm.write {
//            realm.deleteAll()
//        }
        #endif
    }

    private func subscribeViewModel() {
        viewModel.outputs.presentAlert
            .subscribe(onNext: { [weak self] in
                self?.window?.rootViewController?.present($0, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
