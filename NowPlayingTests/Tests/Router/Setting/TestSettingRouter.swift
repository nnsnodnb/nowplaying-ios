//
//  TestSettingRouter.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2022/05/04.
//

@testable import NowPlaying
import RxSwift
import RxTest
import XCTest

final class TestSettingRouter: XCTestCase {
    // MARK: - Properties
    var disposeBag: DisposeBag!
    var testScheduler: TestScheduler!

    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
        disposeBag = .init()
        testScheduler = .init(initialClock: 0)
    }

    override func tearDown() {
        super.tearDown()
        disposeBag = nil
        testScheduler = nil
    }

    func testTwitterの取得() {
        let router = SettingRouter()
        let viewModel = SettingViewModel(router: router)
        let observer = testScheduler.createObserver(Void.self)

        router.twitter.bind(to: observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.item.accept(.socialType(.twitter))

        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events.map { $0.time }, [1])
    }

    func testMastodonの取得() {
        let router = SettingRouter()
        let viewModel = SettingViewModel(router: router)
        let observer = testScheduler.createObserver(Void.self)

        router.mastodon.bind(to: observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.item.accept(.socialType(.mastodon))

        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events.map { $0.time }, [1])
    }

    func testSafariの取得() {
        let router = SettingRouter()
        let viewModel = SettingViewModel(router: router)
        let observer = testScheduler.createObserver(URL.self)

        router.safari.bind(to: observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.item.accept(.link(.developer))

        XCTAssertEqual(observer.events, [.next(1, SettingViewController.Link.developer.url)])
    }

    func testAppStoreの取得() {
        let router = SettingRouter()
        let viewModel = SettingViewModel(router: router)
        let observer = testScheduler.createObserver(Void.self)

        router.appStore.bind(to: observer).disposed(by: disposeBag)
        testScheduler.advanceTo(1)
        viewModel.inputs.item.accept(.review)

        XCTAssertEqual(observer.events.count, 1)
        XCTAssertEqual(observer.events.map { $0.time }, [1])
    }
}
