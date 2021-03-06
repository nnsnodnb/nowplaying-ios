//
//  TwitterSettingRow.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import DTTJailbreakDetection
import Eureka
import Foundation

enum TwitterSettingRow {

    case accounts
    case attachedImageSwitch
    case attachedImageType
    case purchaseAutoTweet((StoreKitAction) -> Void)
    case autoTweetSwitch
    case tweetFormat
    case tweetFormatResetButton(() -> Void)

    var rawValue: String {
        switch self {
        case .accounts:
            return "accounts"
        case .attachedImageSwitch:
            return "attached_image_switch"
        case .attachedImageType:
            return "attached_image_type"
        case .purchaseAutoTweet:
            return "purchase_auto_tweet"
        case .autoTweetSwitch:
            return "auto_tweet_switch"
        case .tweetFormat:
            return "tweet_format"
        case .tweetFormatResetButton:
            return "tweet_format_reset_button"
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
                    return AccountManageViewController.makeInstance(screen: .manage(.twitter))
                }, onDismiss: nil)
            }

        case .attachedImageSwitch:
            return SwitchRow(tag) {
                $0.title = "画像を添付"
                $0.value = UserDefaults.standard.bool(forKey: .isWithImage)
            }.onChange { (row) in
                UserDefaults.standard.set(row.value, forKey: .isWithImage)
            }

        case .attachedImageType:
            return ActionSheetRow<String>(tag) {
                $0.title = "投稿時の画像"
                $0.options = ["アートワークのみ", "再生画面のスクリーンショット"]
                if let value = UserDefaults.standard.string(forKey: .tweetWithImageType) {
                    $0.value = value
                } else {
                    $0.value = $0.options!.first
                    UserDefaults.standard.set($0.value, forKey: .tweetWithImageType)
                }
            }.onChange { (row) in
                UserDefaults.standard.set(row.value, forKey: .tweetWithImageType)
            }

        case .purchaseAutoTweet(let callback):
            return ButtonRow(tag) {
                $0.title = "自動ツイートを購入"
                $0.presentationMode = .presentModally(controllerProvider: .callback {
                    return DTTJailbreakDetection.isJailbroken() ? UIAlertController.jailBreak() : StoreKitAction.createAlert(callback: callback)
                }, onDismiss: nil)
                $0.hidden = Condition(booleanLiteral: UserDefaults.standard.bool(forKey: .isAutoTweetPurchase))
            }

        case .autoTweetSwitch:
            return SwitchRow(tag) {
                $0.title = "自動ツイート"
                $0.value = UserDefaults.standard.bool(forKey: .isAutoTweet)
                $0.hidden = .init(booleanLiteral: !UserDefaults.standard.bool(forKey: .isAutoTweetPurchase))
            }.onChange { (row) in
                UserDefaults.standard.set(row.value, forKey: .isAutoTweet)
            }

        case .tweetFormat:
            return TextAreaRow(tag) {
                $0.placeholder = "ツイートフォーマット"
                $0.value = Service.getPostFormat(.twitter)
            }.onChange {
                let text = $0.value ?? ""
                Service.setPostFormat(.twitter, format: text)
            }

        case .tweetFormatResetButton(let callback):
            return ButtonRow(tag) {
                $0.title = "リセットする"
            }.onCellSelection { (_, _) in
                callback()
            }
        }
    }
}
