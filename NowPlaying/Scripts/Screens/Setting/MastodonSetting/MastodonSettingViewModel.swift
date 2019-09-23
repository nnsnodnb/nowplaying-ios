//
//  MastodonSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Eureka
import Feeder
import FirebaseAnalytics
import Foundation
import KeychainAccess
import RxCocoa
import RxSwift
import SVProgressHUD
import NSURL_QueryDictionary

enum MastodonSettingTransition {
    case manage, alert(AlertConfigurations)
}

// MARK: - MastodonSettingViewModelInput

protocol MastodonSettingViewModelInput {}

// MARK: - MastodonSettingViewModelOutput

protocol MastodonSettingViewModelOutput {

    var form: Form { get }
    var error: Observable<Void> { get }
    var transition: Observable<MastodonSettingTransition> { get }
}

// MARK: - MastodonSettingViewModelType

protocol MastodonSettingViewModelType {

    var inputs: MastodonSettingViewModelInput { get }
    var outputs: MastodonSettingViewModelOutput { get }

    init()
}

final class MastodonSettingViewModelImpl: MastodonSettingViewModelType {

    /* Output */
    let form: Form
    let error: Observable<Void>
    let transition: Observable<MastodonSettingTransition>

    var inputs: MastodonSettingViewModelInput { return self }
    var outputs: MastodonSettingViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let keychain = Keychain.nowPlaying
    private let _error = PublishRelay<Void>()
    private let _transition = PublishRelay<MastodonSettingTransition>()

    private var isMastodonLogin: Bool {
        return UserDefaults.bool(forKey: .isMastodonLogin)
    }

    init() {
        form = Form()
        error = _error.observeOn(MainScheduler.instance).asObservable()
        transition = _transition.observeOn(MainScheduler.instance).asObservable()

        configureCells()
    }
}

// MARK: - Private method (Form)

extension MastodonSettingViewModelImpl {

    private func configureCells() {
        form
            +++ Section("Mastodon")
                <<< configureAccounts()
                <<< configureWith()
                <<< configureWithImageType()
                <<< configureAutoToot()

            +++ Section("投稿フォーマット", configureHeaderForTootFormat())
                <<< configureTootFormat()
                <<< configureFormatReset()
    }

    private func configureAccounts() -> NowPlayingButtonRow {
        return NowPlayingButtonRow {
            $0.title = "アカウント管理"
        }.onCellSelection { [unowned self] (_, _) in
            self._transition.accept(.manage)
        }
    }

    private func configureWith() -> SwitchRow {
        return SwitchRow {
            $0.title = "画像を添付"
            $0.value = UserDefaults.bool(forKey: .isMastodonWithImage)
        }.onChange {
            UserDefaults.set($0.value!, forKey: .isMastodonWithImage)
            Analytics.MastodonSetting.changeWithArtwork($0.value!)
        }
    }

    private func configureWithImageType() -> ActionSheetRow<String> {
        return ActionSheetRow<String> {
            $0.title = "投稿時の画像"
            $0.options = ["アートワークのみ", "再生画面のスクリーンショット"]
            $0.value = UserDefaults.string(forKey: .tootWithImageType)!
        }.onCellSelection { (_, _) in
            Feeder.Impact(.light).impactOccurred()
        }.onChange {
            guard let value = $0.value, let type = WithImageType(rawValue: value) else { return }
            UserDefaults.set(type.rawValue, forKey: .tootWithImageType)
        }
    }

    private func configureAutoToot() -> SwitchRow {
        return SwitchRow {
            $0.title = "自動トゥート"
            $0.value = UserDefaults.bool(forKey: .isMastodonAutoToot)
        }.onChange { [unowned self] in
            UserDefaults.set($0.value!, forKey: .isMastodonAutoToot)
            Analytics.MastodonSetting.changeAutoToot($0.value!)
            if !$0.value! || UserDefaults.bool(forKey: .isMastodonShowAutoTweetAlert) {
                return
            }
            let action = AlertConfigurations.Action(title: "OK", style: .default)
            let configuration = AlertConfigurations(title: "お知らせ", message: "バックグラウンドでもトゥートされますが、iOS上での制約のため長時間には対応できません。", preferredStyle: .alert, actions: [action])
            self._transition.accept(.alert(configuration))
            UserDefaults.set(true, forKey: .isMastodonShowAutoTweetAlert)
            Feeder.Impact(.heavy).impactOccurred()
        }
    }

    private func configureHeaderForTootFormat() -> (Section) -> Void {
        return {
            let postFormatHelpView = R.nib.postFormatHelpView
            $0.footer = HeaderFooterView<PostFormatHelpView>(.nibFile(name: postFormatHelpView.name,
                                                                      bundle: postFormatHelpView.bundle))
        }
    }

    private func configureTootFormat() -> TextAreaRow {
        return TextAreaRow {
            $0.placeholder = "トゥートフォーマット"
            $0.tag = "toot_format"
            $0.value = UserDefaults.string(forKey: .tootFormat)
        }.onChange { (row) in
            guard let value = row.value, !value.isEmpty else { return }
            UserDefaults.set(value, forKey: .tootFormat)
        }
    }

    private func configureFormatReset() -> ButtonRow {
        return ButtonRow {
            $0.title = "リセットする"
        }.onCellSelection { [unowned self] (_, _) in
            let cancel = AlertConfigurations.Action(title: "キャンセル", style: .cancel)
            let reset = AlertConfigurations.Action(title: "リセット", style: .destructive) { [unowned self] (_) in
                DispatchQueue.main.async {
                    guard let tootFormatRow: TextAreaRow = self.form.rowBy(tag: "toot_format") else { return }
                    tootFormatRow.baseValue = String.defaultPostFormat
                    tootFormatRow.updateCell()
                }
            }
            let configuration = AlertConfigurations(title: "投稿フォーマットをリセットします", message: nil, preferredStyle: .alert, actions: [cancel, reset])
            self._transition.accept(.alert(configuration))
            Feeder.Notification(.warning).notificationOccurred()
        }
    }
}

// MARK: - MastodonSettingViewModelInput

extension MastodonSettingViewModelImpl: MastodonSettingViewModelInput {}

// MARK: - MastodonSettingViewModelOutput

extension MastodonSettingViewModelImpl: MastodonSettingViewModelOutput {}
