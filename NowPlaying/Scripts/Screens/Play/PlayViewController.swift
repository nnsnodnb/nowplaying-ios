//
//  PlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/20.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Feeder
import FirebaseAnalytics
import Foundation
import GoogleMobileAds
import MediaPlayer
import RxSwift
import ScrollFlowLabel
import StoreKit
import SVProgressHUD
import UIKit

final class PlayViewController: UIViewController {

    @IBOutlet private weak var artworkImageView: UIImageView! {
        didSet {
            artworkImageView.layer.shadowColor = R.color.artworkShadowColor()!.cgColor
            artworkImageView.layer.shadowOffset = .zero
            artworkImageView.layer.shadowRadius = 20
            artworkImageView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet private weak var songNameLabel: ScrollFlowLabel! {
        didSet {
            if #available(iOS 13.0, *) {
                songNameLabel.textColor = .label
            } else {
                songNameLabel.textColor = .black
            }
            songNameLabel.textAlignment = .center
            songNameLabel.font = .boldSystemFont(ofSize: 21)
            songNameLabel.pauseInterval = 2
            songNameLabel.scrollDirection = .left
            songNameLabel.observeApplicationState()
        }
    }
    @IBOutlet private weak var artistNameLabel: ScrollFlowLabel! {
        didSet {
            if #available(iOS 13.0, *) {
                artistNameLabel.textColor = .label
            } else {
                artistNameLabel.textColor = .black
            }
            artistNameLabel.textAlignment = .center
            artistNameLabel.font = .systemFont(ofSize: 16)
            artistNameLabel.pauseInterval = 2
            artistNameLabel.scrollDirection = .left
            artistNameLabel.observeApplicationState()
        }
    }
    @IBOutlet private weak var previousButton: UIButton! {
        didSet {
            previousButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.musicPlayer.skipToPreviousItem()
                    Analytics.Play.previousButton()
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var playButton: UIButton! {
        didSet {
            playButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    let isPlaying = self.musicPlayer.playbackState == .playing
                    if isPlaying {
                        self.musicPlayer.pause()
                    } else {
                        self.musicPlayer.play()
                    }
                    self.viewModel.inputs.playStateTrigger.accept(isPlaying)
                    Feeder.Impact(.light).impactOccurred()
                    Analytics.Play.playButton(isPlaying: isPlaying)
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var nextButton: UIButton! {
        didSet {
            nextButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.musicPlayer.skipToNextItem()
                    Analytics.Play.nextButton()
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var gearButton: UIButton! {
        didSet {
            gearButton.rx.tap
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] (_) in
                    let viewController = SettingViewController(viewModel: SettingViewModelImpl())
                    let navi = UINavigationController(rootViewController: viewController)
                    navi.modalPresentationStyle = .fullScreen
                    self.present(navi, animated: true, completion: nil)
                    Analytics.Play.gearButton()
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var mastodonButton: UIButton! {
        didSet {
            mastodonButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    defer { Analytics.Play.mastodonButton() }
                    if !User.isExists(service: .mastodon) {
                        self.showLoginRequireAlert()
                        return
                    }

                    self.viewModel.inputs.newPostContentTrigger.accept(.mastodon)
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var twitterButton: UIButton! {
        didSet {
            twitterButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    defer { Analytics.Play.twitterButton() }
                    if !User.isExists(service: .twitter) {
                        self.showLoginRequireAlert()
                        return
                    }

                    self.viewModel.inputs.newPostContentTrigger.accept(.twitter)
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var bannerView: GADBannerView! {
        didSet {
            bannerView.adUnitID = Environments.firebaseAdmobBannerID
            bannerView.adSize = kGADAdSizeBanner
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }
    @IBOutlet private weak var bannerViewHeight: NSLayoutConstraint!

    private let disposeBag = DisposeBag()
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let viewModel: PlayViewModel

    // MARK: - Initializer

    init(viewModel: PlayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: R.nib.playViewController.name, bundle: R.nib.playViewController.bundle)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeViewModel()
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
        viewModel.inputs.launchCountUpTrigger.accept(())
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *), previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            artworkImageView.layer.shadowColor = R.color.artworkShadowColor()!.cgColor
        }
    }

    // MARK: - Private method

    private func subscribeViewModel() {
        viewModel.outputs.nowPlayingItem
            .drive(onNext: { [weak self] (item) in
                guard let wself = self else { return }
                wself.artworkImageView.image = item.artwork?.image(at: wself.artworkImageView.frame.size)
                wself.songNameLabel.text = item.title
                wself.artistNameLabel.text = item.artist
            })
            .disposed(by: disposeBag)

        viewModel.outputs.playButtonImage
            .drive(onNext: { [weak self] (image) in
                self?.playButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.scale
            .drive(onNext: { [weak self] (transform) in
                UIView.animate(withDuration: 0.4) {
                    self?.artworkImageView.transform = transform
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.postContent
            .drive(onNext: { [unowned self] (post) in
                let viewController = TweetViewController(viewModel: TweetViewModel(post), postContent: post)
                let navi = UINavigationController(rootViewController: viewController)
                navi.modalPresentationStyle = .fullScreen
                self.present(navi, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.requestDenied
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (_) in
                let alert = UIAlertController(title: "アプリを使用するには\n許可が必要です", message: "設定しますか？", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "設定画面へ", style: .default) { _ in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    private func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func showLoginRequireAlert() {
        let alert = UIAlertController(title: nil, message: "設定からログインしてください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
