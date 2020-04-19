//
//  TwitterSettingViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol TwitterSettingViewModelInput {}

protocol TwitterSettingViewModelOutput {}

protocol TwitterSettingViewModelType: AnyObject {

    var input: TwitterSettingViewModelInput { get }
    var output: TwitterSettingViewModelOutput { get }
    init(router: TwitterSettingRouter)
}

final class TwitterSettingViewModel: TwitterSettingViewModelType {

    var input: TwitterSettingViewModelInput { return self }
    var output: TwitterSettingViewModelOutput { return self }

    init(router: TwitterSettingRouter) {

    }
}

// MARK: - TwitterSettingViewModelInput

extension TwitterSettingViewModel: TwitterSettingViewModelInput {}

// MARK: - TwitterSettingViewModelOutput

extension TwitterSettingViewModel: TwitterSettingViewModelOutput {}
