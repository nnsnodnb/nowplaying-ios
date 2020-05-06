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
        title = .just("Twitter設定")
        form = .init()

        configureForm()
    }

    func configureForm() {
        func configureCell(row: TwitterSettingRow) -> BaseRow { return row.row }

        form
            +++ Section("Twitter")
                <<< configureCell(row: .accounts)
                <<< configureCell(row: .attachedImageSwitch)
                <<< configureCell(row: .attachedImageType)
                <<< configureCell(row: .purchaseAutoTweet {
                    switch $0 {
                    case .purchase:
                        break
                    case .restore:
                        break
                    case .userCancel:
                        return
                    }
                })
                <<< configureCell(row: .autoTweetSwitch)
            +++ Section("自動フォーマット", postFormatHelpViewFooter)
                <<< configureCell(row: .tweetFormat)
                <<< configureCell(row: .tweetFormatResetButton { [unowned self] in
                    let alert = UIAlertController.resetPostFormat { [weak self] in
                        Service.resetPostFormat(.twitter)
                        let row = self?.form.rowBy(tag: TwitterSettingRow.tweetFormat.tag) as? TextAreaRow
                        row?.value = .defaultPostFormat
                        row?.updateCell()
                    }
                    self.router.present(alert, animated: true, completion: nil)
                })
    }
}

// MARK: - ProviderSettingViewModelInput

extension TwitterSettingViewModel: ProviderSettingViewModelInput {}

// MARK: - TwitterSettingViewModelOutput

extension TwitterSettingViewModel: ProviderSettingViewModelOutput {}
