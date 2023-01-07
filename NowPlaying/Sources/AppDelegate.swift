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

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        self.window = window
        let environment = Environment(
            application: application,
            screen: window.windowScene?.screen ?? .init(),
            window: window
        )
        let viewController = MainViewController(environment: environment)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        return true
    }
}
