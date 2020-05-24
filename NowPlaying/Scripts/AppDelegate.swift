//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import APIKit
import RealmSwift
import RxCocoa
import RxSwift
import SVProgressHUD
import SwifteriOS
import UIKit

#if DEBUG
import DeallocationChecker
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let shared = UIApplication.shared.delegate as! AppDelegate

    lazy var window: UIWindow? = {
        return UIWindow()
    }()

    private let disposeBag = DisposeBag()

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

        checkVersion()

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

    private func checkVersion() {
        let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        Session.shared.rx.response(NowPlayingAppInfoRequest())
            .map { $0.appVersion }
            .subscribe(onSuccess: { [weak self] in
                if currentAppVersion.compare($0.require, options: .numeric) == .orderedAscending {
                    self?.applicationCoordinator.showUpdateAlert(isRequired: true)
                } else if currentAppVersion.compare($0.latest, options: .numeric) == .orderedAscending {
                    self?.applicationCoordinator.showUpdateAlert(isRequired: false)
                }
            }, onError: nil)
            .disposed(by: disposeBag)
    }
}
