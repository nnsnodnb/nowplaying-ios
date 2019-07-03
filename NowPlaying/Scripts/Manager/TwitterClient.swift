//
//  TwitterClient.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import SVProgressHUD
import MediaPlayer
import FirebaseAnalytics

class TwitterClient: NSObject {

    static let shared = TwitterClient()

    var isLogin: Bool {
        // FIXME: Twitterのログインユーザがある確認
        return false
//        return TWTRTwitter.sharedInstance().sessionStore.session() != nil
    }

    // TODO: クライアント作る？
//    var client: TWTRAPIClient? {
//        guard let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID else { return nil }
//        return TWTRAPIClient(userID: userID)
//    }
}
