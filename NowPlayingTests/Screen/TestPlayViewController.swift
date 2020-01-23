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
    let countUpTrigger: PublishRelay<Void> = .init()

    var input: PlayViewModelInput { return self }
    var output: PlayViewModelOutput { return self }
    var artworkImage: Driver<UIImage> {
        return artwork.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }
    var artworkScale: Driver<CGFloat> {
        return scale.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }
    var songName: Driver<String> {
        return song.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }
    var artistName: Driver<String> {
        return artist.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }
    var playButtonImage: Driver<UIImage> {
        return image.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    private let artwork: Observable<UIImage>
    private let scale: Observable<CGFloat>
    private let song: Observable<String>
    private let artist: Observable<String>
    private let image: Observable<UIImage>

    init(router: PlayRouter) {
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

extension PlayViewModelStub: PlayViewModelInput, PlayViewModelOutput {}

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

            FBSnapshotVerifyView(viewController.view, identifier: config.identifier)
        }
    }
}
