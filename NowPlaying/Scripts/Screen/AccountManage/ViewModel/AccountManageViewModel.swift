//
//  AccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol AccountManageViewModelInput {}

protocol AccountManageViewModelOutput {}

protocol AccountManageViewModelType: AnyObject {

    var input: AccountManageViewModelInput { get }
    var output: AccountManageViewModelOutput { get }
    init(router: AccountManageRouter)
}

final class AccountManageViewModel: AccountManageViewModelType {

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    init(router: AccountManageRouter) {

    }
}

// MARK: - AccountManageViewModelInput

extension AccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
