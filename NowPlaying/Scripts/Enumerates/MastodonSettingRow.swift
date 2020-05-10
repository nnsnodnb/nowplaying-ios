//
//  MastodonSettingRow.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import Foundation

enum MastodonSettingRow {

    case accounts
    case attachedImageSwitch
    case attachedImageType
    case autoToot
    case tootFormat
    case tootFormatResetButton(() -> Void)

    var rawValue: String {
        switch self {
        case .accounts:
            return "accounts"
        case .attachedImageSwitch:
            return "attached_image_switch"
        case .attachedImageType:
            return "attached_image_type"
        case .autoToot:
            return "auto_toot"
        case .tootFormat:
            return "toot_format"
        case .tootFormatResetButton:
            return "toot_format_reset_button"
        }
    }

    var tag: String {
        return rawValue
    }

    var row: BaseRow {
        switch self {
        case .accounts:
            return ButtonRow(tag) {
                $0.title = "アカウント管理"
                $0.presentationMode = .show(controllerProvider: .callback {
                    return AccountManageViewController.makeInstance(screen: .manage(.mastodon))
                }, onDismiss: nil)
            }

        case .attachedImageSwitch:
            return SwitchRow(tag) {
                $0.title = "画像を添付"
                $0.value = UserDefaults.standard.bool(forKey: .isMastodonWithImage)
            }.onChange { (row) in
                UserDefaults.standard.set(row.value, forKey: .isMastodonWithImage)
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
            }.onChange { (row) in
                UserDefaults.standard.set(row.value, forKey: .tootWithImageType)
            }

        case .autoToot:
            return SwitchRow(tag) {
                $0.title = "自動トゥート"
                $0.value = UserDefaults.standard.bool(forKey: .isMastodonAutoToot)
            }.onChange { (row) in
                UserDefaults.standard.set(row.value, forKey: .isMastodonAutoToot)
            }

        case .tootFormat:
            return TextAreaRow(tag) {
                $0.placeholder = "トゥートフォーマット"
                $0.value = Service.getPostFormat(.mastodon)
            }.onChange {
                let text = $0.value ?? ""
                Service.setPostFormat(.mastodon, format: text)
            }

        case .tootFormatResetButton(let callback):
            return ButtonRow(tag) {
                $0.title = "リセットする"
            }.onCellSelection { (_, _) in
                callback()
            }
        }
    }
}
