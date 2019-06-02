//
//  PlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/20.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import FirebaseAnalytics
import Foundation
import GoogleMobileAds
import MediaPlayer
import RxSwift
import StoreKit
import SVProgressHUD
import TwitterKit
import UIKit

final class PlayViewController: UIViewController {

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
                    let viewController = SettingViewController()
                    let navi = UINavigationController(rootViewController: viewController)
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

    private var viewModel: PlayViewModelType!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let inputs = PlayViewModelInput(
            previousButton: previousButton.rx.tap.asObservable(), playButton: playButton.rx.tap.asObservable(),
            nextButton: nextButton.rx.tap.asObservable(), mastodonButton: mastodonButton.rx.tap.asObservable(),
            twitterButton: twitterButton.rx.tap.asObservable()
        )
        viewModel = PlayViewModel(inputs: inputs)
        viewModel.outputs.playButtonImage
            .drive(onNext: { [weak self] (image) in
                self?.playButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.loginRequired
            .subscribe(onNext: { [weak self] (_) in
                let alert = UIAlertController(title: nil, message: "設定からログインしてください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.postContent
            .drive(onNext: { [weak self] (post) in
                let viewController = TweetViewController(postContent: post)
                let navi = UINavigationController(rootViewController: viewController)
                self?.present(navi, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
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

    // MARK: - Private method

    private func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
