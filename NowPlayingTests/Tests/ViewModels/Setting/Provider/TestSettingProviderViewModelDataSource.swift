//
//  TestSettingProviderViewModelDataSource.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2023/01/07.
//

@testable import NowPlaying
import XCTest

final class TestSettingProviderViewModelDataSource: XCTestCase {
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

    func testSocialTypeがtwitterなのでTwitter設定のデータソース取得できる() {
        let viewModel = SettingProviderViewModel(router: router, socialType: .twitter)

        let expect: [SettingProviderViewController.SectionModel] = [
            .init(
                model: .socialType(.twitter),
                items: [
                    .detail(.accounts),
                    .toggle(.attachImage),
                    .selection(.attachmentType),
                    .toggle(.auto(.twitter))
                ]
            ),
            .init(
                model: .format,
                items: [
                    .textView,
                    .button(.reset)
                ]
            ),
            .init(
                model: .footer,
                items: [
                    .footerNote
                ]
            )
        ]
        XCTAssertEqual(viewModel.outputs.dataSource, expect)
    }

    func testSocialTypeがmastodonなのでMastodon設定のデータソース取得できる() {
        let viewModel = SettingProviderViewModel(router: router, socialType: .mastodon)

        let expect: [SettingProviderViewController.SectionModel] = [
            .init(
                model: .socialType(.mastodon),
                items: [
                    .detail(.accounts),
                    .toggle(.attachImage),
                    .selection(.attachmentType),
                    .toggle(.auto(.mastodon))
                ]
            ),
            .init(
                model: .format,
                items: [
                    .textView,
                    .button(.reset)
                ]
            ),
            .init(
                model: .footer,
                items: [
                    .footerNote
                ]
            )
        ]
        XCTAssertEqual(viewModel.outputs.dataSource, expect)
    }
}
