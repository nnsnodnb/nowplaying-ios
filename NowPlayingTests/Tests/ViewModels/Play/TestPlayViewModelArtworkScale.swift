//
//  TestPlayViewModelArtworkScale.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2022/05/04.
//

@testable import NowPlaying
import RxSwift
import RxTest
import XCTest

final class TestPlayViewModelArtworkScale: XCTestCase {
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

    func test再生されていないので0_9() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .paused)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(CGFloat.self)

        viewModel.outputs.artworkScale.drive(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [.next(0, 0.9)])
    }

    func test再生されているので1_0() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .playing)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(CGFloat.self)

        viewModel.outputs.artworkScale.drive(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [.next(0, 1.0)])
    }

    func test一時停止から再生が始まったので1_0() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .paused)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(CGFloat.self)

        viewModel.outputs.artworkScale.drive(observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.playPause.accept(())

        XCTAssertEqual(observer.events, [.next(0, 0.9), .next(1, 1.0)])
    }

    func test再生中から一時停止になったので0_9() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .playing)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(CGFloat.self)

        viewModel.outputs.artworkScale.drive(observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.playPause.accept(())

        XCTAssertEqual(observer.events, [.next(0, 1.0), .next(1, 0.9)])
    }
}
