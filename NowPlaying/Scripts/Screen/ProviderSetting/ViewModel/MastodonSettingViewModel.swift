//
//  MastodonSettingViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import Foundation
import RxCocoa
import RxSwift

final class MastodonSettingViewModel: ProviderSettingViewModelType {

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
        title = .just("Mastodon設定")
        form = Form()

        configureForm()
    }

    func configureForm() {

        func configureCell(row: MastodonSettingRow) -> BaseRow { return row.row }

        form
            +++ Section("Mastodon")
                <<< configureCell(row: .accounts)
                <<< configureCell(row: .attachedImageSwitch)
                <<< configureCell(row: .attachedImageType)
                <<< configureCell(row: .autoToot)
            +++ Section("投稿フォーマット", postFormatHelpViewFooter)
                <<< configureCell(row: .tootFormat {
                    var service: Service = .mastodon
                    service.postFormat = $0
                })
                <<< configureCell(row: .tootFormatResetButton)
    }
}

// MARK: - ProviderSettingViewModelInput

extension MastodonSettingViewModel: ProviderSettingViewModelInput {}

// MARK: - ProviderSettingViewModelOutput

extension MastodonSettingViewModel: ProviderSettingViewModelOutput {}
