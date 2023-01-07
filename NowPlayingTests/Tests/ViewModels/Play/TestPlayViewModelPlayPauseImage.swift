//
//  TestPlayViewModelPlayPauseImage.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2022/05/04.
//

@testable import NowPlaying
import RxSwift
import RxTest
import XCTest

final class TestPlayViewModelPlayPauseImage: XCTestCase {
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

    func test再生されていないので再生ボタン() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .paused)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(UIImage.self)

        viewModel.outputs.playPauseImage.drive(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [.next(0, .init(systemSymbol: .playFill))])
    }

    func test再生されているので一時停止ボタン() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .playing)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(UIImage.self)

        viewModel.outputs.playPauseImage.drive(observer).disposed(by: disposeBag)

        XCTAssertEqual(observer.events, [.next(0, .init(systemSymbol: .pauseFill))])
    }

    func test一時停止中から再生が始まったので一時停止ボタン() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .paused)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(UIImage.self)

        viewModel.outputs.playPauseImage.drive(observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.playPause.accept(())

        XCTAssertEqual(observer.events, [.next(0, .init(systemSymbol: .playFill)), .next(1, .init(systemSymbol: .pauseFill))])
    }

    func test再生中から一時停止になったので再生ボタン() {
        let mediaItem = StubMediaItem(title: "タイトル", artist: "アーティスト", artwork: nil)
        let musicPlayerController = StubMusicPlayerController(mediaItem: mediaItem, playbackState: .playing)
        let viewModel = PlayViewModel(router: router, musicPlayerController: musicPlayerController)
        let observer = testScheduler.createObserver(UIImage.self)

        viewModel.outputs.playPauseImage.drive(observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.playPause.accept(())

        XCTAssertEqual(observer.events, [.next(0, .init(systemSymbol: .pauseFill)), .next(1, .init(systemSymbol: .playFill))])
    }
}
