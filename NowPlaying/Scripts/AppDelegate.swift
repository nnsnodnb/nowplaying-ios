//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import DeallocationChecker
import RealmSwift
import SVProgressHUD
import SwifteriOS
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = UIApplication.shared.delegate as! AppDelegate

    lazy var window: UIWindow? = {
        return UIWindow()
    }()

    private(set) lazy var applicationCoordinator: ApplicationCoordinator = {
        return .init(window: window!)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        createInitialData()
        applicationCoordinator.start()

        SVProgressHUD.setDefaultMaskType(.black)

        #if DEBUG
        let realmEncryptionKeyString = realmConfiguration.encryptionKey!.map { String(format: "%.2hhx", $0) }.joined()
        print("🔑 Realm encryption key: \(realmEncryptionKeyString)")

        DeallocationChecker.shared.setup()
        #endif
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Swifter.handleOpenURL(url)
        return true
    }

    // MARK: - Private method

    private func createInitialData() {
        if UserDefaults.standard.string(forKey: .tweetFormat) == nil {
            UserDefaults.standard.set(.defaultPostFormat, forKey: .tweetFormat)
        }
        if UserDefaults.standard.string(forKey: .tootFormat) == nil {
            UserDefaults.standard.set(.defaultPostFormat, forKey: .tootFormat)
        }
        if UserDefaults.standard.string(forKey: .tweetWithImageType) == nil {
            UserDefaults.standard.set("アートワークのみ", forKey: .tweetWithImageType)
        }
        if UserDefaults.standard.string(forKey: .tootWithImageType) == nil {
            UserDefaults.standard.set("アートワークのみ", forKey: .tootWithImageType)
        }
    }
}
