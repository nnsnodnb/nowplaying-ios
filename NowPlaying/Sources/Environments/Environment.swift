//
//  Environment.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import Foundation

final class Environment: EnvironmentProtocol {
    // MARK: - Properties
    let application: UIApplicationProtocol
    let screen: UIScreenProtocol
    let window: UIWindowProtocol

    // MARK: - Initialize
    init(
        application: UIApplicationProtocol,
        screen: UIScreenProtocol,
        window: UIWindowProtocol
    ) {
        self.application = application
        self.screen = screen
        self.window = window
    }
}
