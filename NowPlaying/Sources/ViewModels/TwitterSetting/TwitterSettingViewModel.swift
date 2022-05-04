//
//  TwitterSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import Foundation

protocol TwitterSettingViewModelInputs: AnyObject {
}

protocol TwitterSettingViewModelOutputs: AnyObject {
}

protocol TwitterSettingViewModelType: AnyObject {
    var inputs: TwitterSettingViewModelInputs { get }
    var outputs: TwitterSettingViewModelOutputs { get }
}

final class TwitterSettingViewModel: TwitterSettingViewModelType {
    // MARK: - Inputs Sources
    // MARK: - Outputs Sources
    // MARK: - Properties
    var inputs: TwitterSettingViewModelInputs { return self }
    var outputs: TwitterSettingViewModelOutputs { return self }

    private let router: TwitterSettingRoutable

    // MARK: - Initialize
    init(router: TwitterSettingRoutable) {
        self.router = router
    }
}

// MARK: - TwitterSettingViewModelInputs
extension TwitterSettingViewModel: TwitterSettingViewModelInputs {}

// MARK: - TwitterSettingViewModelOutputs
extension TwitterSettingViewModel: TwitterSettingViewModelOutputs {}
