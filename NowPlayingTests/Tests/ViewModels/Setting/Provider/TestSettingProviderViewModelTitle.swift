//
//  TestSettingProviderViewModelTitle.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2023/01/07.
//

@testable import NowPlaying
import XCTest

final class TestSettingProviderViewModelTitle: XCTestCase {
    // MARK: - Properties
    private var router: SettingProviderRoutable!

    // MARK: - Life Cycle
    override func setUp() {
        super.setUp()
        router = StubSettingProviderRouter()
    }

    override func tearDown() {
        super.tearDown()
        router = nil
    }

    func testSocialTypeがtwitterなのでTwitter設定が取得できる() {
        let viewModel = SettingProviderViewModel(router: router, socialType: .twitter)

        XCTAssertEqual(viewModel.outputs.title, "Twitter設定")
    }

    func testSocialTypeがmastodonなのでMastodon設定が取得できる() {
        let viewModel = SettingProviderViewModel(router: router, socialType: .mastodon)

        XCTAssertEqual(viewModel.outputs.title, "Mastodon設定")
    }
}
