//
//  Analytics+NowPlaying.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import FirebaseAnalytics
import Foundation
import UIKit

// MARK: - PlayViewController

extension Analytics {

    final class Play: Analytics {

        static func previousButton() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "previous"])
        }

        static func playButton(isPlaying: Bool) {
            logEvent("tap", parameters: [
                "type": "action",
                "button": isPlaying ? "pause" : "play"])
        }

        static func nextButton() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "next"]
            )
        }

        static func mastodonButton() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "mastodon"])
        }

        static func twitterButton() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "twitter"])
        }

        static func gearButton() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "setting"])
        }
    }
}

// MARK: - TweetViewController

extension Analytics {

    final class Tweet: Analytics {

        static func cancelPost(isMastodon: Bool) {
            logEvent("tap", parameters: [
                "type": isMastodon ? "mastodon" : "twitter",
                "button": "post_close"])
        }

        static func postTweetTwitter(withHasImage hasImage: Bool, content: PostContent) {
            logEvent("post", parameters: [
                "type": "twitter",
                "auto_post": false,
                "image": hasImage,
                "artist_name": content.artistName,
                "song_name": content.songTitle])
        }

        static func postTootMastodon(withHasImage hasImage: Bool, content: PostContent) {
            logEvent("post", parameters: [
                "type": "mastodon",
                "auto_post": false,
                "image": hasImage,
                "artist_name": content.artistName,
                "song_name": content.songTitle])
        }
    }
}

// MARK: - SettingViewController

extension Analytics {

    final class Setting: Analytics {

        static func onTapDeveloper() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "developer_twitter"])
        }

        static func github() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "github_respository"])
        }

        static func review() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "appstore_review",
                "os": UIDevice.current.systemVersion])
        }
    }
}

// MARK: - TwitterSettingViewController

extension Analytics {

    final class TwitterSetting: Analytics {

        static func login() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "twitter_login"])
        }

        static func logout() {
            logEvent("tap", parameters: [
                "type": "action",
                "button": "twitter_logout"])
        }

        static func changeWithArtwork(_ value: Bool) {
            logEvent("change", parameters: [
                "type": "action",
                "button": "twitter_with_artwork",
                "value": value])
        }
    }
}
