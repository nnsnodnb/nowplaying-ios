//
//  TwitterClient.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import TwitterKit
import SVProgressHUD
import MediaPlayer
import FirebaseAnalytics

class TwitterClient: NSObject {

    static let shared = TwitterClient()

    var isLogin: Bool {
        return TWTRTwitter.sharedInstance().sessionStore.session() != nil
    }

    var client: TWTRAPIClient? {
        guard let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID else { return nil }
        return TWTRAPIClient(userID: userID)
    }

    func autoTweet(_ song: MPMediaItem?, resultCompletion: @escaping ((Bool, Error?) -> Void)) {
        // オートツイート購入なし or オートツイートオフの場合、早期終了
        if !UserDefaults.bool(forKey: .isAutoTweetPurchase) || !UserDefaults.bool(forKey: .isAutoTweet) {
            return
        }
        // Twitterログインなしの場合、早期終了
        if TWTRTwitter.sharedInstance().sessionStore.session() == nil {
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
            TwitterClient.shared.client?.sendTweet(withText: message, image: image!) { (_, error) in
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
            TwitterClient.shared.client?.sendTweet(withText: message) { (_, error) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    resultCompletion(error == nil, error)
                }
            }
        }
    }
}
