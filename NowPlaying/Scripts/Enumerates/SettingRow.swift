//
//  SettingRow.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import Foundation
import SafariServices
import StoreKit

enum SettingRow: String {

    case twitter
    case mastodon
    case developer
    case sourceCode
    case featureReportsAndBugs
    case review

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
        case .review:
            return "レビューする"
        }
    }

    var presentationMode: PresentationMode<UIViewController>? {
        switch self {
        case .twitter:
            // FIXME: Twitter設定画面
            break
        case .mastodon:
            // FIXME: Mastodon設定画面
            break

        case .developer:
            return getSFSafariViewControllerCallback(string: "https://twitter.com/nnsnodnb")

        case .sourceCode:
            return getSFSafariViewControllerCallback(string: "https://github.com/nnsnodnb/nowplaying-ios")

        case .featureReportsAndBugs:
            return getSFSafariViewControllerCallback(string: "https://forms.gle/gE5ms3bEM5A85kdVA")

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

        // TODO: TwitterとMastodon設定画面実装後に削除する
        return getSFSafariViewControllerCallback(string: "https://www.google.com")
    }

    private func getSFSafariViewControllerCallback(string: String) -> PresentationMode<UIViewController> {
        return .presentModally(controllerProvider: .callback {
            return SFSafariViewController(url: URL(string: string)!)
        }, onDismiss: nil)
    }
}
