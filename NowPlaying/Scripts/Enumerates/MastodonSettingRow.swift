//
//  MastodonSettingRow.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import Foundation

enum MastodonSettingRow: String {

    case accounts
    case attachedImageSwitch
    case attachedImageType
    case autoToot
    case tootFormat
    case tootFormatResetButton

    var tag: String {
        return rawValue
    }

    var row: BaseRow {
        switch self {
        case .accounts:
            return ButtonRow(tag) {
                $0.title = "アカウント管理"
                $0.presentationMode = .show(controllerProvider: .callback {
                    return AccountManageViewController.makeInstance(service: .mastodon)
                }, onDismiss: nil)
            }

        case .attachedImageSwitch:
            return SwitchRow(tag) {
                $0.title = "画像を添付"
                $0.value = UserDefaults.standard.bool(forKey: .isMastodonWithImage)
            }

        case .attachedImageType:
            return ActionSheetRow<String>(tag) {
                $0.title = "投稿時の画像"
                $0.options = ["アートワークのみ", "再生画面のスクリーンショット"]
                if let value = UserDefaults.standard.string(forKey: .tootWithImageType) {
                    $0.value = value
                } else {
                    $0.value = $0.options!.first
                    UserDefaults.standard.set($0.value, forKey: .tootWithImageType)
                }
            }

        case .autoToot:
            return SwitchRow(tag) {
                $0.title = "自動トゥート"
                $0.value = UserDefaults.standard.bool(forKey: .isMastodonAutoToot)
            }

        case .tootFormat:
            return TextAreaRow(tag) {
                $0.placeholder = "トゥートフォーマット"
                $0.value = UserDefaults.standard.string(forKey: .tootFormat)
            }

        case .tootFormatResetButton:
            return ButtonRow(tag) {
                $0.title = "リセットする"
            }
        }
    }
}
