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

    static var client: TWTRAPIClient {
        return TWTRAPIClient(userID: Twitter.sharedInstance().sessionStore.session()?.userID)
    }

    func get() -> String {
        let url = "https://api.twitter.com/1.1/statuses/update.json"
        var error: NSError?
        let client = TwitterClient.client
        let request = client.urlRequest(withMethod: "POST", url: url, parameters: ["status": "test"], error: &error)
        return request.allHTTPHeaderFields?.description ?? ""
    }

    func tweet(text: String, handler: ((Error?) -> Void)?) {
        let url = "https://api.twitter.com/1.1/statuses/update.json"
        var error: NSError?
        let client = TwitterClient.client
        let request = client.urlRequest(withMethod: "POST", url: url, parameters: ["status": text], error: &error)
        client.sendTwitterRequest(request) { (response, data, error) in
            guard let response = response as? HTTPURLResponse, error == nil, response.statusCode == 200 else {
                handler?(error!)
                return
            }
            handler?(nil)
        }
    }
}
