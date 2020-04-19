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

protocol AccountManageViewModelInput {

    var addTrigger: PublishRelay<Void> { get }
    var editTrigger: PublishRelay<Void> { get }
}

protocol AccountManageViewModelOutput {}

protocol AccountManageViewModelType: AnyObject {

    var input: AccountManageViewModelInput { get }
    var output: AccountManageViewModelOutput { get }
    init(router: AccountManageRouter)
}

final class AccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(router: AccountManageRouter) {

    }
}

// MARK: - AccountManageViewModelInput

extension AccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
