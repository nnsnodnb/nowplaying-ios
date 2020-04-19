//
//  StoreKitAction.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

enum StoreKitAction: CaseIterable {

    case purchase
    case restore
    case userCancel

    static func createAlert(callback: ((StoreKitAction) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "購入しますか？復元しますか？", message: "", preferredStyle: .alert)
        StoreKitAction.allCases.forEach { (action) in
            let alertAction = action.alertAction(callback: callback)
            alert.addAction(alertAction)
            if action.isPreferredAction { alert.preferredAction = alertAction }
        }
        return alert
    }

    func alertAction(callback: ((StoreKitAction) -> Void)?) -> UIAlertAction {
        return .init(title: title, style: style) { (_) in
            callback?(self)
        }
    }

    var title: String? {
        switch self {
        case .purchase:
            return "購入"
        case .restore:
            return "復元"
        case .userCancel:
            return "キャンセル"
        }
    }

    var style: UIAlertAction.Style {
        return self == .userCancel ? .cancel : .default
    }

    var isPreferredAction: Bool {
        return self == .purchase
    }
}
