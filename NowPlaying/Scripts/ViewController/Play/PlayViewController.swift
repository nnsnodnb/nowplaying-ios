//
//  PlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/20.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import TwitterKit
import SVProgressHUD
import Floaty
import FirebaseAnalytics
import StoreKit
import GoogleMobileAds

class PlayViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var floaty: Floaty!
    @IBOutlet weak var floatyBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!

    var albumTitle: String! {
        didSet {
            title = albumTitle
        }
    }
    var song: MPMediaItem? {
        didSet {
            artworkImageView.image = song?.artwork?.image(at: artworkImageView.frame.size)
            songNameLabel.text = song?.title
        }
    }
    var isNotification: Bool = false {
        didSet {
            if !isNotification {
                return
            }
            autoTweet()
            autoToot()
        }
    }

    fileprivate var isPlay: Bool = MPMusicPlayerController.systemMusicPlayer.playbackState == .playing {
        didSet {
            playButton.setImage(UIImage(named: isPlay ? "pause" : "play"), for: .normal)
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layoutFAB()
        setupBanner()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("再生画面", screenClass: "PlayViewController")
        Analytics.logEvent("screen_open", parameters: nil)
        countUpOpenCount()
        showPurchaseInfo()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        floatyBottomMargin.constant = 16
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    fileprivate func layoutFAB() {
        let item = FloatyItem()
        item.hasShadow = false
        item.buttonColor = UIColor.blue
        item.circleShadowColor = UIColor.red
        item.titleShadowColor = UIColor.blue
        item.titleLabelPosition = .left
        item.title = "titlePosition right"

        floaty.hasShadow = false
        floaty.addItem("Twitter", icon: #imageLiteral(resourceName: "twitter")) { [unowned self] item in
            DispatchQueue.main.async {
                self.onTapTwitterButton(item)
            }
        }
        floaty.addItem("Mastodon", icon: #imageLiteral(resourceName: "mastodon")) { [unowned self] item in
            DispatchQueue.main.async {
                self.onTapMastodonButton(item)
            }
        }
    }

    fileprivate func setupView() {
        songNameLabel.text = nil
        isPlay = MPMusicPlayerController.systemMusicPlayer.playbackState == .playing
    }

    private func setupBanner() {
        bannerView.adUnitID = ProcessInfo.processInfo.environment[EnvironmentKey.firebaseAdmobBannerId.rawValue]
        bannerView.adSize = kGADAdSizeBanner
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }

    fileprivate func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    fileprivate func autoTweet() {
        guard UserDefaults.standard.bool(forKey: UserDefaultsKey.isAutoTweet.rawValue) || Twitter.sharedInstance().sessionStore.session() != nil else { return }
        SVProgressHUD.show()
        let message = "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying"
        if let artwork = song?.artwork, UserDefaults.standard.bool(forKey: UserDefaultsKey.isWithImage.rawValue) {
            let image = artwork.image(at: artwork.bounds.size)
            Analytics.logEvent("post", parameters: [
                "type": "tweet",
                "auto_post": true,
                "image": true,
                "artist_name": song?.artist ?? "",
                "song_name": song?.title ?? ""]
            )
            TwitterClient.shared.client?.sendTweet(withText: message, image: image!) { [unowned self] (tweet, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showError(error: error!)
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
            TwitterClient.shared.client?.sendTweet(withText: message) { [unowned self] (tweet, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showError(error: error!)
                }
            }
        }
    }

    fileprivate func autoToot() {
        if !UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonAutoToot.rawValue) || !UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonLogin.rawValue) {
            return
        }
        SVProgressHUD.show()
        let message = "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying"
        if let artwork = song?.artwork, UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonWithImage.rawValue) {
            let image = artwork.image(at: artwork.bounds.size)
            Analytics.logEvent("post", parameters: [
                "type": "mastodon",
                "auto_post": true,
                "image": true,
                "artist_name": song?.artist ?? "",
                "song_name": song?.title ?? ""]
            )
            MastodonClient.shared.toot(text: message, image: image, handler: { (error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showError(error: error!)
                }
            })
        } else {
            Analytics.logEvent("post", parameters: [
                "type": "tweet",
                "auto_post": true,
                "image": false,
                "artist_name": song?.artist ?? "",
                "song_name": song?.title ?? ""]
            )
            MastodonClient.shared.toot(text: message, handler: { (error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showError(error: error!)
                }
            })
        }
    }

    // MARK: - Floaty's items target

    func onTapTwitterButton(_ sender: FloatyItem) {
        if Twitter.sharedInstance().sessionStore.session() == nil {
            let alert = UIAlertController(title: nil, message: "設定からログインしてください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "twitter"]
        )
        let tweetViewController = TweetViewController()
        tweetViewController.tweetText = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem != nil ? "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying" : nil
        if let artwork = song?.artwork, UserDefaults.standard.bool(forKey: UserDefaultsKey.isWithImage.rawValue) {
            let image = artwork.image(at: artwork.bounds.size)
            tweetViewController.shareImage = image
        }
        tweetViewController.artistName = song?.artist ?? ""
        tweetViewController.songName = song?.title ?? ""
        let navi = UINavigationController(rootViewController: tweetViewController)
        present(navi, animated: true, completion: nil)
    }

    func onTapMastodonButton(_ sender: FloatyItem) {
        if !UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonLogin.rawValue) {
            let alert = UIAlertController(title: nil, message: "設定からログインしてください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "mastodon"]
        )
        let tweetViewController = TweetViewController()
        tweetViewController.tweetText = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem != nil ? "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying" : nil
        if let artwork = song?.artwork, UserDefaults.standard.bool(forKey: UserDefaultsKey.isMastodonWithImage.rawValue) {
            let image = artwork.image(at: artwork.bounds.size)
            tweetViewController.shareImage = image
        }
        tweetViewController.artistName = song?.artist ?? ""
        tweetViewController.songName = song?.title ?? ""
        tweetViewController.isMastodon = true
        let navi = UINavigationController(rootViewController: tweetViewController)
        present(navi, animated: true, completion: nil)
    }

    fileprivate func countUpOpenCount() {
        var count = UserDefaults.standard.integer(forKey: UserDefaultsKey.appOpenCount.rawValue)
        count += 1
        UserDefaults.standard.set(count, forKey: UserDefaultsKey.appOpenCount.rawValue)
        UserDefaults.standard.synchronize()
        if count == 15 {
            SKStoreReviewController.requestReview()
        }
    }

    /* 2.0.1のみ使用 */
    private func showPurchaseInfo() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.update2_1_0.rawValue) {
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = NSTimeZone.system
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let untilFreePurchaseDate = dateFormatter.date(from: "2018-04-20"), untilFreePurchaseDate < Date() {
            return
        }
        let alert = UIAlertController(title: "自動ツイートについてのお知らせ",
                                      message: "自動ツイートの機能のみ課金制になりました。なお2018年4月20日までに設定画面より無料で入手することが可能です。お試しください。",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async { [unowned self] in
            self.present(alert, animated: true) {
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.update2_1_0.rawValue)
                UserDefaults.standard.synchronize()
            }
        }
    }

    // MARK: - IBAction

    @IBAction func onTapPreviousButton(_ sender: Any) {
        MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "previous"]
        )
    }

    @IBAction func onTapPlayButton(_ sender: Any) {
        if isPlay {
            MPMusicPlayerController.systemMusicPlayer.pause()
        } else {
            MPMusicPlayerController.systemMusicPlayer.play()
        }
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": isPlay ? "previous" : "play"]
        )
        isPlay = !isPlay
    }

    @IBAction func onTapNextButton(_ sender: Any) {
        MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "next"]
        )
    }

    @IBAction func onTapGearButton(_ sender: Any) {
        let settingViewController = SettingViewController()
        let navi = UINavigationController(rootViewController: settingViewController)
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "setting"]
        )
        present(navi, animated: true, completion: nil)
    }
}

