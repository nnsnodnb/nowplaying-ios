//
//  TestPlayViewModelArtworkImage.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2022/05/04.
//

import MediaPlayer
@testable import NowPlaying
import RxSwift
import RxTest
import XCTest

final class TestPlayViewModelArtworkImage: XCTestCase {
    // MARK: - Properties
    var router: PlayerRoutable!
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!

    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
        router = StubPlayerRouter()
        disposeBag = .init()
        testScheduler = .init(initialClock: 0)
    }

    override func tearDown() {
        super.tearDown()
        router = nil
        disposeBag = nil
        testScheduler = nil
    }

    func test再生している曲がないのでic_music() {
        let musicPlayerController = StubMusicPlayerController(mediaItem: nil, playbackState: .stopped)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(UIImage.self)

        viewModel.outputs.artworkImage.drive(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [.next(0, Asset.Assets.icMusic.image)])
    }

    func test再生している曲があるのでアートワーク() {
        let image = UIColor.red.image(.init(width: 100, height: 100))
        let artwork = MPMediaItemArtwork(boundsSize: .init(width: 1, height: 1)) { _ in image }
        let mediaItem = StubMediaItem(title: "タイトル",
                                      artist: "アーティスト",
                                      artwork: artwork)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .paused)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(UIImage.self)

        viewModel.outputs.artworkImage.drive(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [.next(0, image)])
    }
}
