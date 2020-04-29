//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RealmSwift
import SVProgressHUD
import SwifteriOS
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = {
        return UIWindow()
    }()

    private(set) lazy var applicationCoordinator: ApplicationCoordinator = {
        return .init(window: window!)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applicationCoordinator.start()

        SVProgressHUD.setDefaultMaskType(.black)

        #if DEBUG
        let realmEncryptionKeyString = realmConfiguration.encryptionKey!.map { String(format: "%.2hhx", $0) }.joined()
        print("🔑 Realm encryption key: \(realmEncryptionKeyString)")
        #endif
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return Swifter.handleOpenURL(url, callbackURL: .twitterCallbackURL)
    }
}
