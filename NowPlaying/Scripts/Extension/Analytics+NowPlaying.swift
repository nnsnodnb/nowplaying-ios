//
//  Analytics+NowPlaying.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import FirebaseAnalytics
import Foundation

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
