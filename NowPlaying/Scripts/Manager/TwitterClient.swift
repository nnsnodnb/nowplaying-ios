//
//  TwitterClient.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import ExtensionCollection
import TwitterKit

class TwitterClient: NSObject {

    static let shared = TwitterClient()

    var client: TWTRAPIClient? {
        get {
            if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
                return TWTRAPIClient(userID: userID)
            } else {
                return nil
            }
        }
    }
}
