//
//  PaymentProduct.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/06.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum PaymentProduct: String {

    case autoTweet = "moe.nnsnodnb.NowPlaying.autoTweet"
    case hideAdMob = "moe.nnsnodnb.NowPlaying.hideAdMob"

    var userDefaultsKey: UserDefaults.Key {
        switch self {
        case .autoTweet:
            return .isAutoTweetPurchase
        case .hideAdMob:
            return .isPurchasedRemoveAdMob
        }
    }

    func finishPurchased() {
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }
}
