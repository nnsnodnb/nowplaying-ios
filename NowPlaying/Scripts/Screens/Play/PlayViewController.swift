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
import RxSwift
import StoreKit
import GoogleMobileAds

class PlayViewController: UIViewController {

    @IBOutlet private weak var artworkImageView: UIImageView!
    @IBOutlet private weak var songNameLabel: UILabel!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var gearButton: UIButton! {
        didSet {
            gearButton.rx.tap
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [weak self] (_) in
                    let settingViewController = R.storyboard.setting.instantiateInitialViewController()!
                    let navi = UINavigationController(rootViewController: settingViewController)
                    Analytics.logEvent("tap", parameters: [
                        "type": "action",
                        "button": "setting"]
                    )
                    self?.present(navi, animated: true, completion: nil)
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var mastodonButton: UIButton!
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var bannerView: GADBannerView! {
        didSet {
            bannerView.adUnitID = ProcessInfo.processInfo.get(forKey: .firebaseAdmobBannerId)
            bannerView.adSize = kGADAdSizeBanner
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }
    @IBOutlet private weak var bannerViewHeight: NSLayoutConstraint!

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

    private let disposeBag = DisposeBag()

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
    private var viewModel: PlayViewModelType!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let inputs = PlayViewModelInput(
            previousButton: previousButton.rx.tap.asObservable(),
            playButton: playButton.rx.tap.asObservable(),
            nextButton: nextButton.rx.tap.asObservable()
        )
        viewModel = PlayViewModel(inputs: inputs)
        viewModel.outputs.playButtonImage
            .drive(onNext: { [weak self] (image) in
                self?.playButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)

        setupNotification()
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
        viewModel.countUpOpenCount()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }

    // MARK: - Private method

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(receivePlaybackStateDidChange(_:)),
                                               name: .MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
    }

    private func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - IBAction

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
