//
//  TwitterSettingViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import Foundation
import RxCocoa
import RxSwift

protocol TwitterSettingViewModelInput {}

protocol TwitterSettingViewModelOutput {

    var form: Form { get }
}

protocol TwitterSettingViewModelType: AnyObject {

    var input: TwitterSettingViewModelInput { get }
    var output: TwitterSettingViewModelOutput { get }
    init(router: TwitterSettingRouter)
}

final class TwitterSettingViewModel: TwitterSettingViewModelType {

    let form: Form

    var input: TwitterSettingViewModelInput { return self }
    var output: TwitterSettingViewModelOutput { return self }

    private lazy var postFormatHelpViewFooter: (Section) -> Void = {
        return {
            $0.footer = HeaderFooterView<PostFormatHelpView>(.callback {
                return R.nib.postFormatHelpView(owner: nil)!
            })
        }
    }()

    init(router: TwitterSettingRouter) {
        form = Form()

        configureForm()
    }
}

// MARK: - Private method

extension TwitterSettingViewModel {

    private func configureForm() {

        func configureCell(row: TwitterSettingRow) -> BaseRow { return row.row }

        form
            +++ Section("Twitter")
                <<< configureCell(row: .accounts)
                <<< configureCell(row: .attachedImageSwitch)
                <<< configureCell(row: .attachedImageType)
                <<< configureCell(row: .purchaseAutoTweet {
                    print($0) // TODO: Implementation
                })
                <<< configureCell(row: .autoTweetSwitch)
            +++ Section("自動フォーマット", postFormatHelpViewFooter)
                <<< configureCell(row: .tweetFormat)
                <<< configureCell(row: .tweetFormatResetButton)
    }
}

// MARK: - TwitterSettingViewModelInput

extension TwitterSettingViewModel: TwitterSettingViewModelInput {}

// MARK: - TwitterSettingViewModelOutput

extension TwitterSettingViewModel: TwitterSettingViewModelOutput {}
