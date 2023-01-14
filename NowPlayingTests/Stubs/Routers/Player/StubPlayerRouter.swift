//
//  StubPlayerRouter.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2023/01/07.
//

@testable import NowPlaying
import RxCocoa
import UIKit

final class StubPlayerRouter: PlayerRoutable {
    // MARK: - Properties
    let setting: PublishRelay<Void> = .init()
    let twitter: PublishRelay<MediaItem> = .init()
    let mastodon: PublishRelay<MediaItem> = .init()

    private(set) weak var viewController: UIViewController?

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
