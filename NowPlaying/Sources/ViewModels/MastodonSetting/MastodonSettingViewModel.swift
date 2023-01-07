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
}

protocol MastodonSettingViewModelType: AnyObject {
    var inputs: MastodonSettingViewModelInput { get }
    var outputs: MastodonSettingViewModelOutput { get }
}

final class MastodonSettingViewModel: MastodonSettingViewModelType {
    // MARK: - Properties
    var inputs: MastodonSettingViewModelInput { return self }
    var outputs: MastodonSettingViewModelOutput { return self }

    private let router: MastodonSettingRoutable

    // MARK: - Initialize
    init(router: MastodonSettingRoutable) {
        self.router = router
    }
}

// MARK: - MastodonSettingViewModelInput
extension MastodonSettingViewModel: MastodonSettingViewModelInput {}

// MARK: - MastodonSettingViewModelOutput
extension MastodonSettingViewModel: MastodonSettingViewModelOutput {}
