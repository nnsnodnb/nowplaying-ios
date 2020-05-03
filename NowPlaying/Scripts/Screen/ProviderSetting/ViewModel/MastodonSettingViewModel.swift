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

    private let router: ProviderSettingRoutable

    private lazy var postFormatHelpViewFooter: (Section) -> Void = {
        return {
            $0.footer = HeaderFooterView<PostFormatHelpView>(.callback {
                return R.nib.postFormatHelpView(owner: nil)!
            })
        }
    }()

    init(router: ProviderSettingRoutable) {
        self.router = router
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
                <<< configureCell(row: .tootFormat)
                <<< configureCell(row: .tootFormatResetButton { [unowned self] in
                    let alert = UIAlertController.resetPostFormat { [weak self] in
                        Service.resetPostFormat(.mastodon)
                        let row = self?.form.rowBy(tag: MastodonSettingRow.tootFormat.tag) as? TextAreaRow
                        row?.value = .defaultPostFormat
                        row?.updateCell()
                    }
                    self.router.present(alert, animated: true, completion: nil)
                })
    }
}

// MARK: - ProviderSettingViewModelInput

extension MastodonSettingViewModel: ProviderSettingViewModelInput {}

// MARK: - ProviderSettingViewModelOutput

extension MastodonSettingViewModel: ProviderSettingViewModelOutput {}
