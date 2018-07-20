//
//  TwitterClient.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import ExtensionCollection
import TwitterKit
import SVProgressHUD
import MediaPlayer
import FirebaseAnalytics

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

    func autoTweet(_ song: MPMediaItem?, resultCompletion: @escaping ((Bool, Error?) -> Void)) {
        // オートツイート購入なし or オートツイートオフの場合、早期終了
        if !UserDefaults.bool(forKey: .isAutoTweetPurchase) || !UserDefaults.bool(forKey: .isAutoTweet) {
            return
        }
        // Twitterログインなしの場合、早期終了
        if Twitter.sharedInstance().sessionStore.session() == nil {
            return
        }

        SVProgressHUD.show()
        let message = "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying"

        // アートワークがある and アートワーク付与の場合、真
        if let artwork = song?.artwork, UserDefaults.bool(forKey: .isWithImage) {
            let image = artwork.image(at: artwork.bounds.size)
            Analytics.logEvent("post", parameters: [
                "type": "tweet",
                "auto_post": true,
                "image": true,
                "artist_name": song?.artist ?? "",
                "song_name": song?.title ?? ""]
            )
            TwitterClient.shared.client?.sendTweet(withText: message, image: image!) { (tweet, error) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    resultCompletion(error == nil, error)
                }
            }
        } else {
            Analytics.logEvent("post", parameters: [
                "type": "tweet",
                "auto_post": true,
                "image": false,
                "artist_name": song?.artist ?? "",
                "song_name": song?.title ?? ""]
            )
            TwitterClient.shared.client?.sendTweet(withText: message) { (tweet, error) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    resultCompletion(error == nil, error)
                }
            }
        }
    }
}
