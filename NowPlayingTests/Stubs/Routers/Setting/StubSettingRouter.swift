//
//  StubSettingRouter.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2023/01/07.
//

@testable import NowPlaying
import RxCocoa
import UIKit

final class StubSettingRouter: SettingRoutable {
    // MARK: - Properties
    let dismiss: PublishRelay<Void> = .init()
    let twitter: PublishRelay<Void> = .init()
    let mastodon: PublishRelay<Void> = .init()
    let safari: PublishRelay<URL> = .init()
    let appStore: PublishRelay<Void> = .init()

    private(set) weak var viewController: UIViewController?

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
