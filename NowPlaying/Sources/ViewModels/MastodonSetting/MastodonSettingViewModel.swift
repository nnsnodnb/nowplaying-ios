//
//  MastodonSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import Foundation

protocol MastodonSettingViewModelInput: AnyObject {
}

protocol MastodonSettingViewModelOutput: AnyObject {
    var dataSource: [MastodonSettingViewController.SectionModel] { get }
}

protocol MastodonSettingViewModelType: AnyObject {
    var inputs: MastodonSettingViewModelInput { get }
    var outputs: MastodonSettingViewModelOutput { get }
}

final class MastodonSettingViewModel: MastodonSettingViewModelType {
    // MARK: - Inputs Sources
    // MARK: - Outputs Sources
    let dataSource: [MastodonSettingViewController.SectionModel]
    // MARK: - Properties
    var inputs: MastodonSettingViewModelInput { return self }
    var outputs: MastodonSettingViewModelOutput { return self }

    private let router: MastodonSettingRoutable

    // MARK: - Initialize
    init(router: MastodonSettingRoutable) {
        self.dataSource = [
            .init(
                model: .mastodon,
                items: [
                    .detail(.accounts),
                    .toggle(.attachImage),
                    .selection(.attachmentType),
                    .toggle(.auto)
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
        self.router = router
    }
}

// MARK: - MastodonSettingViewModelInput
extension MastodonSettingViewModel: MastodonSettingViewModelInput {}

// MARK: - MastodonSettingViewModelOutput
extension MastodonSettingViewModel: MastodonSettingViewModelOutput {}
