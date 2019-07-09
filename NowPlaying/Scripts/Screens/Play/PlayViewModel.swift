//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import FirebaseAnalytics
import FirebaseAuth
import MediaPlayer
import PopupDialog
import RxCocoa
import RxSwift
import StoreKit
import UIKit

struct PlayViewModelInput {

    let viewController: UIViewController
    let previousButton: Observable<Void>
    let playButton: Observable<Void>
    let nextButton: Observable<Void>
    let mastodonButton: Observable<Void>
    let twitterButton: Observable<Void>
}

// MARK: - PlayViewModelOutput

protocol PlayViewModelOutput {

    var nowPlayingItem: Driver<MPMediaItem> { get }
    var playButtonImage: Driver<UIImage?> { get }
    var loginRequired: Observable<Void> { get }
    var postContent: Driver<PostContent> { get }
    var requestDenied: Observable<Void> { get }
}

// MARK: - PlayViewModelType

protocol PlayViewModelType {

    var outputs: PlayViewModelOutput { get }
    init(inputs: PlayViewModelInput)
    func countUpOpenCount()
    func applyNowPlayItem()
    func showSingleAccountToMultiAccountDialog()
}

final class PlayViewModel: PlayViewModelType {

    var outputs: PlayViewModelOutput { return self }

    private let viewController: UIViewController
    private let isPlaying: BehaviorRelay<Bool>
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let disposeBag = DisposeBag()
    private let _nowPlayingItem = BehaviorRelay<MPMediaItem?>(value: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem)
    private let loginError = PublishRelay<Void>()
    private let _postContent = PublishRelay<PostContent>()
    private let _requestDenied = PublishRelay<Void>()

    private var twitterPostContent: PostContent!
    private var mastodonPostContent: PostContent!

    init(inputs: PlayViewModelInput) {
        viewController = inputs.viewController
        isPlaying = BehaviorRelay(value: musicPlayer.playbackState == .playing)

        musicPlayer.beginGeneratingPlaybackNotifications()

        setupNotificationObserver()
        setupInputObserver(inputs)
        setupUserDefaultsObserver()
    }

    func countUpOpenCount() {
        var count = UserDefaults.integer(forKey: .appOpenCount)
        count += 1
        UserDefaults.set(count, forKey: .appOpenCount)
        if count == 15 {
            SKStoreReviewController.requestReview()
            UserDefaults.set(0, forKey: .appOpenCount)
        }
    }

    func applyNowPlayItem() {
        twitterPostContent = createNewPostCotent(service: .twitter)
        mastodonPostContent = createNewPostCotent(service: .mastodon)
        autoPostControl(twitter: twitterPostContent, mastodon: mastodonPostContent)
    }

    // シングルアカウントログインの頃にインストールされていた場合、ポップアップを表示する
    func showSingleAccountToMultiAccountDialog() {
        if UserDefaults.bool(forKey: .singleAccountToMultiAccounts) { return }
        let version = Bundle.main.object(forInfoDictionaryKey: .bundleShortVersionString) as! String
        // バージョンが2.4.0のとき場合、表示対象にする
        if version.compare("2.4.0", options: .numeric) != .orderedSame {
            UserDefaults.set(true, forKey: .singleAccountToMultiAccounts)
            return
        }

        guard Auth.auth().currentUser != nil && !UserDefaults.bool(forKey: .isMastodonLogin) else {
            UserDefaults.set(true, forKey: .singleAccountToMultiAccounts)
            return
        }
        let dialog = PopupDialog(title: "お知らせ", message: "アカウント切り替えに対応しました！\n左下の歯車ボタンからもう一度ログインをお願いします",
                                 buttonAlignment: .horizontal, transitionStyle: .zoomIn, tapGestureDismissal: false,
                                 panGestureDismissal: false, hideStatusBar: true, completion: nil)
        let cancelButton = CancelButton(title: "あとで", action: nil)
        let goSettingButton = DefaultButton(title: "設定する") { [unowned self] in
            DispatchQueue.main.async {
                let navi = UINavigationController(rootViewController: SettingViewController())
                self.viewController.present(navi, animated: true, completion: nil)
            }
        }
        dialog.addButtons([cancelButton, goSettingButton])
        let dialogVC = dialog.viewController as! PopupDialogDefaultViewController
        dialogVC.messageFont = .boldSystemFont(ofSize: 17)
        dialogVC.messageColor = .black
        AuthManager.oldLogout()
        viewController.present(dialog, animated: true) {
            UserDefaults.set(true, forKey: .singleAccountToMultiAccounts)
        }
    }

    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }
}

// MARK: - Private method (Subscribe)

extension PlayViewModel {

    private func setupNotificationObserver() {
        // 再生状態の変更
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
            .subscribe(onNext: { [weak self] (_) in
                self?.isPlaying.accept(self?.musicPlayer.playbackState == .playing)
            })
            .disposed(by: disposeBag)

        // 再生されている曲の変更
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .subscribe(onNext: { [weak self] (notification) in
                guard let wself = self, let player = notification.object as? MPMusicPlayerController else { return }
                wself._nowPlayingItem.accept(player.nowPlayingItem)
            })
            .disposed(by: disposeBag)

        MPMediaLibrary.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
                Observable<Int>.timer(.milliseconds(500), scheduler: MainScheduler.instance)
                    .subscribe(onNext: { [weak self] (_) in
                        self?._nowPlayingItem.accept(self?.musicPlayer.nowPlayingItem)
                    })
                    .disposed(by: self.disposeBag)
            case .denied:
                self._requestDenied.accept(())
            case .notDetermined, .restricted:
                break
            @unknown default:
                break
            }
        }
    }

    private func setupInputObserver(_ inputs: PlayViewModelInput) {
        inputs.previousButton
            .subscribe(onNext: { () in
                MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
                Analytics.Play.previousButton()
            })
            .disposed(by: disposeBag)

        inputs.playButton
            .subscribe(onNext: { [weak self] (_) in
                let isPlay = MPMusicPlayerController.systemMusicPlayer.playbackState == .playing
                if isPlay {
                    MPMusicPlayerController.systemMusicPlayer.pause()
                } else {
                    MPMusicPlayerController.systemMusicPlayer.play()
                }
                Analytics.Play.playButton(isPlaying: isPlay)
                self?.isPlaying.accept(isPlay)
            })
            .disposed(by: disposeBag)

        inputs.nextButton
            .subscribe(onNext: { (_) in
                MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
                Analytics.Play.nextButton()
            })
            .disposed(by: disposeBag)

        inputs.mastodonButton
            .subscribe(onNext: { [weak self] (_) in
                defer { Analytics.Play.mastodonButton() }
                if !User.isExists(service: .mastodon) {
                    self?.loginError.accept(())
                    return
                }

                self?.setNewPostContent(service: .mastodon)
            })
            .disposed(by: disposeBag)

        inputs.twitterButton
            .subscribe(onNext: { [weak self] (_) in
                defer { Analytics.Play.twitterButton() }
                if !User.isExists(service: .twitter) {
                    self?.loginError.accept(())
                    return
                }

                self?.setNewPostContent(service: .twitter)
            })
            .disposed(by: disposeBag)
    }

    private func setupUserDefaultsObserver() {
        // ツイートに添付する画像タイプが変更 or ツイートフォーマットが変更
        let twitterColletion = [
            UserDefaults.standard.rx.change(String.self, .tweetWithImageType),
            UserDefaults.standard.rx.change(String.self, .tweetFormat)
        ]
        Observable<Void>
            .combineLatest(twitterColletion) { _ in }
            .subscribe(onNext: { [weak self] in
                self?.twitterPostContent = self?.createNewPostCotent(service: .twitter)
            })
            .disposed(by: disposeBag)

        // トゥートに添付する画像タイプが変更 or トゥートフォーマットが変更
        let mastodonCollection = [
            UserDefaults.standard.rx.change(String.self, .tootWithImageType),
            UserDefaults.standard.rx.change(String.self, .tootFormat)
        ]
        Observable<Void>
            .combineLatest(mastodonCollection) { _ in }
            .subscribe(onNext: { [weak self] in
                self?.mastodonPostContent = self?.createNewPostCotent(service: .mastodon)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private method (Utilities)

extension PlayViewModel {

    /* 再生されている曲が変わるたびに新しく生成 */
    private func createNewPostCotent(service: Service) -> PostContent {
        guard let item = _nowPlayingItem.value else {
            return PostContent(postMessage: "", shareImage: nil, songTitle: "", artistName: "", service: service)
        }
        var postText = UserDefaults.string(forKey: service.postTextFormatUserDefaultsKey)!

        let title = item.title ?? "不明なタイトル"
        let artist = item.artist ?? "不明なアーティスト"
        let album = item.albumTitle ?? "不明なアルバム"
        postText = postText.replacingOccurrences(of: "__songtitle__", with: title)
        postText = postText.replacingOccurrences(of: "__artist__", with: artist)
        postText = postText.replacingOccurrences(of: "__album__", with: album)

        let shareImage = getShareImage(service: service, item: item)

        return PostContent(postMessage: postText, shareImage: shareImage, songTitle: title, artistName: artist, service: service)
    }

    /* 添付画像の取得 */
    private func getShareImage(service: Service, item: MPMediaItem) -> UIImage? {
        switch WithImageType(rawValue: UserDefaults.string(forKey: service.withImageTypeUserDefaultsKey)!)! {
        case .onlyArtwork:
            guard let artwork = item.artwork, let image = artwork.image(at: artwork.bounds.size) else { return nil }
            return image
        case .playerScreenshot:
            let rect = UIScreen.main.bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
            defer { UIGraphicsEndImageContext() }
            let context = UIGraphicsGetCurrentContext()!

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController?.view.layer.render(in: context)

            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }

    /* 実際に遷移先に持っていくコンテンツの設定 */
    private func setNewPostContent(service: Service) {
        var content: PostContent
        let key: UserDefaultsKey
        switch service {
        case .twitter:
            content = twitterPostContent
            key = .isWithImage
        case .mastodon:
            content = mastodonPostContent
            key = .isMastodonWithImage
        }
        // 画像添付が設定されていないので画像を削除
        if !UserDefaults.bool(forKey: key) { content.removeShareImage() }
        _postContent.accept(content)
    }

    private func autoPostControl(twitter: PostContent, mastodon: PostContent) {
        guard _nowPlayingItem.value != nil else { return }
        var tweetContent = twitter
        var mastodonContent = mastodon
        if !UserDefaults.bool(forKey: .isWithImage) { tweetContent.removeShareImage() }
        if !UserDefaults.bool(forKey: .isMastodonWithImage) { mastodonContent.removeShareImage() }
        postTweet(tweetContent)
        postMastodon(mastodonContent)
    }

    private func postTweet(_ content: PostContent) {
        guard UserDefaults.bool(forKey: .isAutoTweetPurchase) && UserDefaults.bool(forKey: .isAutoTweet) else { return }
        if let shareImage = content.shareImage {
//            TwitterClient.shared.client?.sendTweet(withText: content.postMessage, image: shareImage) { (_, _) in }
            // FIXME: 画像つきツイートを送信する
            Analytics.AutoPost.withImageTweet(content)
        } else {
//            TwitterClient.shared.client?.sendTweet(withText: content.postMessage) { (_, _) in }
            // FIXME: ツイートを送信する
            Analytics.AutoPost.textOnlyTweet(content)
        }
    }

    private func postMastodon(_ content: PostContent) {
        guard UserDefaults.bool(forKey: .isMastodonAutoToot) else { return }
        if let shareImage = content.shareImage, let data = shareImage.pngData() {
            // FIXME: User オブジェクトを取得する
//            Session.shared.rx.response(MastodonMediaRequest(imageData: data))
//                .subscribe(onSuccess: { [weak self] (response) in
//                    guard let wself = self else { return }
//                    Session.shared.rx.response(MastodonTootRequest(status: content.postMessage, mediaIDs: [response.mediaID]))
//                        .subscribe(onSuccess: { (_) in
//                        }, onError: { (error) in
//                            print(error)
//                        })
//                        .disposed(by: wself.disposeBag)
//                }, onError: { (error) in
//                    print(error)
//                })
//                .disposed(by: disposeBag)
            Analytics.AutoPost.withImageToot(content)
        } else {
            // FIXME: User オブジェクトを取得する
//            Session.shared.rx.response(MastodonTootRequest(status: content.postMessage))
//                .subscribe(onSuccess: { (_) in
//
//                }, onError: { (error) in
//                    print(error)
//                })
//                .disposed(by: disposeBag)
            Analytics.AutoPost.textOnlyToot(content)
        }
    }
}

// MARK: - PlayViewModelOutput

extension PlayViewModel: PlayViewModelOutput {

    var nowPlayingItem: SharedSequence<DriverSharingStrategy, MPMediaItem> {
        return _nowPlayingItem
            .compactMap { $0 }
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
    }

    var playButtonImage: SharedSequence<DriverSharingStrategy, UIImage?> {
        return isPlaying
            .map { $0 ? R.image.pause() : R.image.play() }
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: nil)
    }

    var loginRequired: Observable<Void> {
        return loginError.observeOn(MainScheduler.instance).asObservable()
    }

    var postContent: SharedSequence<DriverSharingStrategy, PostContent> {
        return _postContent.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    var requestDenied: Observable<Void> {
        return _requestDenied.observeOn(MainScheduler.instance).asObservable()
    }
}
