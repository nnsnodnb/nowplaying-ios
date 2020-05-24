//
//  TestPlayViewController.swift
//  NowPlayingTests
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import FBSnapshotTestCase
import RxCocoa
import RxSwift
import UIKit
import XCTest
@testable import NowPlaying

final class PlayViewModelStub: PlayViewModelType {

    let playPauseButtonTrigger: PublishRelay<Void> = .init()
    let previousButtonTrigger: PublishRelay<Void> = .init()
    let nextButtonTrigger: PublishRelay<Void> = .init()
    let gearButtonTrigger: PublishRelay<Void> = .init()
    let mastodonButtonTrigger: PublishRelay<Void> = .init()
    let twitterButtonTrigger: PublishRelay<Void> = .init()
    let countUpTrigger: PublishRelay<Void> = .init()
    let tookScreenshot: PublishRelay<UIImage> = .init()

    var inputs: PlayViewModelInput { return self }
    var outputs: PlayViewModelOutput { return self }
    var artworkImage: Observable<UIImage> {
        return artwork.observeOn(MainScheduler.instance)
    }
    var artworkScale: Observable<CGFloat> {
        return scale.observeOn(MainScheduler.instance)
    }
    var songName: Observable<String> {
        return song.observeOn(MainScheduler.instance)
    }
    var artistName: Observable<String> {
        return artist.observeOn(MainScheduler.instance)
    }
    var playButtonImage: Observable<UIImage> {
        return image.observeOn(MainScheduler.instance)
    }
    var takeScreenshot: Observable<Void> { return .empty() }
    var hideAdMob: Observable<Bool> { return .just(false) }

    private let artwork: Observable<UIImage>
    private let scale: Observable<CGFloat>
    private let song: Observable<String>
    private let artist: Observable<String>
    private let image: Observable<UIImage>

    init(router: PlayRoutable) {
        artwork = .empty()
        scale = .empty()
        song = .empty()
        artist = .empty()
        image = .empty()
    }

    init(artwork: UIImage, scale: CGFloat, song: String, artist: String, image: UIImage) {
        self.artwork = .just(artwork)
        self.scale = .just(scale)
        self.song = .just(song)
        self.artist = .just(artist)
        self.image = .just(image)
    }
}

// MARK: - PlayViewModelInput

extension PlayViewModelStub: PlayViewModelInput {}

// MARK: - PlayViewModelOutput

extension PlayViewModelStub: PlayViewModelOutput {}

final class TestPlayViewController: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordMode = false
        folderName = "再生画面"
        fileNameOptions = [.screenSize, .screenScale, .OS]
    }

    func test表示() {

        struct Config {
            let artwork: UIImage
            let scale: CGFloat
            let song: String
            let artist: String
            let image: UIImage
            let identifier: String
        }

        let configs: [Config] = [
            .init(artwork: R.image.music()!, scale: 0.9, song: "", artist: "", image: R.image.play()!, identifier: "音楽なし"),
            .init(artwork: iconImage, scale: 0.9, song: "曲名", artist: "アーティスト名", image: R.image.play()!, identifier: "停止中"),
            .init(artwork: iconImage, scale: 0.9, song: "曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名",
                  artist: "アーティスト名", image: R.image.play()!, identifier: "停止中長い曲名"),
            .init(artwork: iconImage, scale: 1, song: "曲名", artist: "アーティスト名", image: R.image.pause()!, identifier: "再生中"),
            .init(artwork: iconImage, scale: 1, song: "曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名曲名",
                  artist: "アーティスト名", image: R.image.pause()!, identifier: "再生中長い曲名"),
        ]
        for config in configs {
            let viewController = PlayViewController()
            let viewModel = PlayViewModelStub(artwork: config.artwork, scale: config.scale, song: config.song, artist: config.artist, image: config.image)
            viewController.inject(dependency: .init(viewModel: viewModel))
            viewController.view.frame = .init(origin: .zero, size: UIScreen.main.bounds.size)

            FBSnapshotVerifyView(viewController.view, identifier: config.identifier)
        }
    }
}
