//
//  ProviderSettingViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import Foundation
import RxCocoa
import RxSwift

protocol ProviderSettingViewModelInput {}

protocol ProviderSettingViewModelOutput {

    var title: Observable<String> { get }
    var form: Form { get }
}

protocol ProviderSettingViewModelType: AnyObject {

    var input: ProviderSettingViewModelInput { get }
    var output: ProviderSettingViewModelOutput { get }
    init(router: ProviderSettingRoutable)
    func configureForm()
}
