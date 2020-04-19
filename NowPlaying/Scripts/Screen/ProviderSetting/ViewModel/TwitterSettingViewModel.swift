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

final class TwitterSettingViewModel: ProviderSettingViewModelType {

    let title: Observable<String>
    let form: Form

    var input: ProviderSettingViewModelInput { return self }
    var output: ProviderSettingViewModelOutput { return self }

    private lazy var postFormatHelpViewFooter: (Section) -> Void = {
        return {
            $0.footer = HeaderFooterView<PostFormatHelpView>(.callback {
                return R.nib.postFormatHelpView(owner: nil)!
            })
        }
    }()

    init(router: ProviderSettingRouter) {
        title = .just("Twitter設定")
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

// MARK: - ProviderSettingViewModelInput

extension TwitterSettingViewModel: ProviderSettingViewModelInput {}

// MARK: - TwitterSettingViewModelOutput

extension TwitterSettingViewModel: ProviderSettingViewModelOutput {}
