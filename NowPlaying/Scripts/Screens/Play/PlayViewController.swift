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
import FirebaseAnalytics
import StoreKit
import GoogleMobileAds

class PlayViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!

    var albumTitle: String! {
        didSet {
            title = albumTitle
        }
    }
    var song: MPMediaItem? {
        didSet {
            DispatchQueue.main.async {
                self.artworkImageView.image = self.song?.artwork?.image(at: self.artworkImageView.frame.size)
                self.songNameLabel.text = self.song?.title
            }
        }
    }
    var isNotification: Bool = false {
        didSet {
            if !isNotification {
                return
            }
            TwitterClient.shared.autoTweet(song) { [weak self] (result, error) in
                if let wself = self, let error = error, !result {
                    DispatchQueue.main.async {
                        wself.showError(error: error)
                    }
                }
            }
            MastodonClient.shared.autoToot(song) { [weak self] (result, error) in
                if let wself = self, let error = error, !result {
                    DispatchQueue.main.async {
                        wself.showError(error: error)
                    }
                }
            }
        }
    }

    private var isPlay: Bool  {
        get {
            return MPMusicPlayerController.systemMusicPlayer.playbackState == .playing
        }
        set {
            DispatchQueue.main.async {
                self.playButton.setImage(UIImage(named: newValue ? "pause" : "play"), for: .normal)
            }
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupView()
        setupBanner()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard UserDefaults.bool(forKey: .isPurchasedRemoveAdMob) else { return }
        bannerView.isHidden = true
        bannerViewHeight.constant = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("再生画面", screenClass: "PlayViewController")
        Analytics.logEvent("screen_open", parameters: nil)
        countUpOpenCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }

    // MARK: - Private method

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivePlaybackStateDidChange(_:)),
                                               name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }

    private func setupView() {
        songNameLabel.text = nil
        isPlay = MPMusicPlayerController.systemMusicPlayer.playbackState == .playing
    }

    private func setupBanner() {
        bannerView.adUnitID = ProcessInfo.processInfo.get(forKey: .firebaseAdmobBannerId)
        bannerView.adSize = kGADAdSizeBanner
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }

    private func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func countUpOpenCount() {
        var count = UserDefaults.integer(forKey: .appOpenCount)
        count += 1
        UserDefaults.set(count, forKey: .appOpenCount)
        if count == 15 {
            SKStoreReviewController.requestReview()
            UserDefaults.set(0, forKey: .appOpenCount)
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
        let isPlay = MPMusicPlayerController.systemMusicPlayer.playbackState == .playing
        if isPlay {
            MPMusicPlayerController.systemMusicPlayer.pause()
        } else {
            MPMusicPlayerController.systemMusicPlayer.play()
        }
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": isPlay ? "pause" : "play"]
        )
        self.isPlay = !isPlay
    }

    @IBAction func onTapNextButton(_ sender: Any) {
        MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "next"]
        )
    }

    @IBAction func onTapGearButton(_ sender: Any) {
        guard let settingViewController = R.storyboard.setting.instantiateInitialViewController() else {
            return
        }
        let navi = UINavigationController(rootViewController: settingViewController)
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "setting"]
        )
        present(navi, animated: true, completion: nil)
    }

    @IBAction func onTapMastodonButton(_ sender: Any) {
        if !UserDefaults.bool(forKey: .isMastodonLogin) {
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
        if let artwork = song?.artwork, UserDefaults.bool(forKey: .isMastodonWithImage) {
            let image = artwork.image(at: artwork.bounds.size)
            tweetViewController.shareImage = image
        }
        tweetViewController.artistName = song?.artist ?? ""
        tweetViewController.songName = song?.title ?? ""
        tweetViewController.isMastodon = true
        let navi = UINavigationController(rootViewController: tweetViewController)
        present(navi, animated: true, completion: nil)
    }

    @IBAction func onTapTwitterButton(_ sender: Any) {
        if TWTRTwitter.sharedInstance().sessionStore.session() == nil {
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
        if let artwork = song?.artwork, UserDefaults.bool(forKey: .isWithImage) {
            let image = artwork.image(at: artwork.bounds.size)
            tweetViewController.shareImage = image
        }
        tweetViewController.artistName = song?.artist ?? ""
        tweetViewController.songName = song?.title ?? ""
        let navi = UINavigationController(rootViewController: tweetViewController)
        present(navi, animated: true, completion: nil)
    }

    // MARK: - Notification target

    @objc private func receivePlaybackStateDidChange(_ notification: Notification) {
        isPlay = MPMusicPlayerController.systemMusicPlayer.playbackState == .playing
    }
}
