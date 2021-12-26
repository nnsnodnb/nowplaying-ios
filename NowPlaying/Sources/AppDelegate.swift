//
//  AppDelegate.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties
    var window: UIWindow?

    private let mainViewController: MainViewController = {
        let viewController = MainViewController()
        return viewController
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = .init(frame: UIScreen.main.bounds)
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        return true
    }
}
