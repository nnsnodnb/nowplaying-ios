//
//  StubEnvironment.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2023/01/07.
//

import Foundation
@testable import NowPlaying

final class StubEnvironment: EnvironmentProtocol {
    // MARK: - Properties
    let application: UIApplicationProtocol
    let screen: UIScreenProtocol
    let window: UIWindowProtocol

    static let stub: StubEnvironment = {
        return .init(
            application: StubUIApplication(),
            screen: StubUIScreen(),
            window: StubUIWindow()
        )
    }()

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
