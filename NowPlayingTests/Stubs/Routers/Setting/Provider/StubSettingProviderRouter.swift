//
//  StubSettingProviderRouter.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2023/01/07.
//

@testable import NowPlaying
import UIKit

final class StubSettingProviderRouter: SettingProviderRoutable {
    // MARK: - Proerties
    private(set) weak var viewController: UIViewController?

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
