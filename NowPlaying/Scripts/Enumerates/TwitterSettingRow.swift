//
//  TwitterSettingRow.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import Foundation

enum TwitterSettingRow {

    case accounts
    case attachedImageSwitch
    case attachedImageType
    case purchaseAutoTweet((StoreKitAction) -> Void)
    case autoTweetSwitch

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
                // FIXME: presentationMode
            }

        case .attachedImageSwitch:
            return SwitchRow(tag) {
                $0.title = "画像を添付"
                $0.value = UserDefaults.standard.bool(forKey: .isWithImage)
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
            }

        case .purchaseAutoTweet:
            return ButtonRow(tag) {
                $0.title = "自動ツイートを購入"
                // FIXME: presentationMode
                $0.hidden = Condition(booleanLiteral: UserDefaults.standard.bool(forKey: .isAutoTweetPurchase))
            }

        case .autoTweetSwitch:
            return SwitchRow(tag) {
                $0.title = "自動ツイート"
                $0.value = UserDefaults.standard.bool(forKey: .isAutoTweet)
            }
        }
    }
}
