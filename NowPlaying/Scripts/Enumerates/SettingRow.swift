//
//  SettingRow.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import DTTJailbreakDetection
import Eureka
import Foundation
import SafariServices
import StoreKit

enum SettingRow {

    case twitter
    case mastodon
    case developer
    case sourceCode
    case featureReportsAndBugs
    case purchaseHideAdMob((StoreKitAction) -> Void)
    case review

    var rawValue: String {
        switch self {
        case .twitter:
            return "twitter"
        case .mastodon:
            return "mastodon"
        case .developer:
            return "developer"
        case .sourceCode:
            return "source_code"
        case .featureReportsAndBugs:
            return "feature_reports_and_bugs"
        case .purchaseHideAdMob:
            return "purchase_hide_admob"
        case .review:
            return "review"
        }
    }

    var tag: String {
        return rawValue
    }

    var title: String {
        switch self {
        case .twitter:
            return "Twitter設定"
        case .mastodon:
            return "Mastodon設定"
        case .developer:
            return "開発者(Twitter)"
        case .sourceCode:
            return "ソースコード(GitHub)"
        case .featureReportsAndBugs:
            return "機能要望・バグ報告"
        case .purchaseHideAdMob:
            return "アプリ内広告削除(有料)"
        case .review:
            return "レビューする"
        }
    }

    var presentationMode: PresentationMode<UIViewController>? {
        switch self {
        case .twitter:
            return .show(controllerProvider: .callback {
                return ProviderSettingViewController.makeInstance(provider: .twitter)
            }, onDismiss: nil)

        case .mastodon:
            return .show(controllerProvider: .callback {
                return ProviderSettingViewController.makeInstance(provider: .mastodon)
            }, onDismiss: nil)

        case .developer:
            return getSFSafariViewControllerCallback(string: "https://twitter.com/nnsnodnb")

        case .sourceCode:
            return getSFSafariViewControllerCallback(string: "https://github.com/nnsnodnb/nowplaying-ios")

        case .featureReportsAndBugs:
            return getSFSafariViewControllerCallback(string: "https://forms.gle/gE5ms3bEM5A85kdVA")

        case .purchaseHideAdMob(let callback):
            return .presentModally(controllerProvider: .callback {
                return DTTJailbreakDetection.isJailbroken() ? UIAlertController.jailBreak() : StoreKitAction.createAlert(callback: callback)
            }, onDismiss: nil)

        case .review:
            return .presentModally(controllerProvider: .callback {
                let alert = UIAlertController(title: "AppStoreが開きます", message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "キャンセル", style: .cancel, handler: nil))
                alert.addAction(.init(title: "開く", style: .default, handler: { (_) in
                    let url = URL(string: "\(websiteURL)&action=write-review")!
                    DispatchQueue.main.async {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }))
                alert.preferredAction = alert.actions.last
                return alert
            }, onDismiss: nil)
        }
    }

    var hidden: Condition? {
        switch self {
        case .purchaseHideAdMob:
            return .init(booleanLiteral: UserDefaults.standard.bool(forKey: .isPurchasedRemoveAdMob))
        default:
            return nil
        }
    }

    private func getSFSafariViewControllerCallback(string: String) -> PresentationMode<UIViewController> {
        return .presentModally(controllerProvider: .callback {
            return SFSafariViewController(url: URL(string: string)!)
        }, onDismiss: nil)
    }
}
