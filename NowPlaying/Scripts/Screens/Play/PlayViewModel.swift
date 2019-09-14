//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import Feeder
import FirebaseAnalytics
import FirebaseAuth
import MediaPlayer
import PopupDialog
import RxCocoa
import RxSwift
import StoreKit
import SVProgressHUD
import Swifter
import UIKit

// MARK: PlayViewModelInput

protocol PlayViewModelInput {

    var playStateTrigger: BehaviorRelay<Bool> { get }
    var loginErrorTrigger: PublishRelay<Void> { get }
    var newPostContentTrigger: PublishRelay<Service> { get }
    var launchCountUpTrigger: PublishRelay<Void> { get }
}

// MARK: - PlayViewModelOutput

protocol PlayViewModelOutput {

    var nowPlayingItem: Driver<MPMediaItem> { get }
    var playButtonImage: Driver<UIImage?> { get }
    var scale: Driver<CGAffineTransform> { get }
    var postContent: Driver<PostContent> { get }
    var requestDenied: Observable<Void> { get }
}

// MARK: - PlayViewModelType

protocol PlayViewModel {

    var inputs: PlayViewModelInput { get }
    var outputs: PlayViewModelOutput { get }
    init()
}

final class PlayViewModelImpl: PlayViewModel {

    /* PlayViewModel */
    var inputs: PlayViewModelInput { return self }
    var outputs: PlayViewModelOutput { return self }

    /* PlayViewModelInput */
    let playStateTrigger: BehaviorRelay<Bool>
    let loginErrorTrigger: PublishRelay<Void> = .init()
    let newPostContentTrigger: PublishRelay<Service> = .init()
    let launchCountUpTrigger: PublishRelay<Void> = .init()

    /* Action */
    // テキストのみ・メディア込みポストアクション (Twitter)
    private let tweetStatusAction: Action<(SecretCredential, String, Data?), JSON> = .init {
        return TwitterPostRequest(credential: $0.0).postTweet(status: $0.1, media: $0.2)
    }
    // テキストのみ・メディア込みポストアクション (Mastodon)
    private let tootStatusAction: Action<(SecretCredential, String, [String]?), Void> = .init {
        return Session.shared.rx.response(MastodonTootRequest(secret: $0.0, status: $0.1, mediaIDs: $0.2))
    }
    // メディアアップロードアクション (Mastodon)
    private let tootUploadMediaAction: Action<(SecretCredential, Data), MastodonMediaResponse> = .init {
        return Session.shared.rx.response(MastodonMediaRequest(secret: $0.0, imageData: $0.1))
    }

    /* Properties */
    private let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    private let disposeBag = DisposeBag()
    private let _nowPlayingItem = BehaviorRelay<MPMediaItem?>(value: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem)
    private let _postContent = PublishRelay<PostContent>()
    private let _requestDenied = PublishRelay<Void>()

    private var twitterPostContent: PostContent!
    private var mastodonPostContent: PostContent!

    // MARK: - Life cycle

    init() {
        playStateTrigger = .init(value: musicPlayer.playbackState == .playing)

        musicPlayer.beginGeneratingPlaybackNotifications()

        setupNotificationObserver()
        setupActionObserver()
        setupInputObserver()
        setupUserDefaultsObserver()
    }

    deinit {
        musicPlayer.endGeneratingPlaybackNotifications()
    }
}

// MARK: - Private method (Subscribe)

extension PlayViewModelImpl {

    private func setupNotificationObserver() {
        // 再生状態の変更
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
            .subscribe(onNext: { [weak self] (_) in
                self?.playStateTrigger.accept(self?.musicPlayer.playbackState == .playing)
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

    private func setupActionObserver() {
        tweetStatusAction.elements
            .map { _ in }
            .subscribe(onNext: {
                SVProgressHUD.dismiss()
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)

        tootStatusAction.elements
            .subscribe(onNext: {
                SVProgressHUD.dismiss()
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)

        tootUploadMediaAction.elements
            .subscribe(onNext: { [weak self] (response) in
                guard let wself = self,
                    let user = User.getDefaultUser(service: .mastodon),
                    let secret = user.secretCredentials.first else { return }
                wself.tootStatusAction.inputs.onNext((secret, wself.mastodonPostContent.postMessage, [response.mediaID]))
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: disposeBag)
    }

    private func setupInputObserver() {
        newPostContentTrigger
            .subscribe(onNext: { [unowned self] (service) in
                let content = self.createNewPostCotent(service: service)
                self._postContent.accept(content)
            })
            .disposed(by: disposeBag)

        launchCountUpTrigger
            .subscribe(onNext: {
                var count = UserDefaults.integer(forKey: .appOpenCount)
                count += 1
                UserDefaults.set(count, forKey: .appOpenCount)
                if count == 15 {
                    SKStoreReviewController.requestReview()
                    UserDefaults.set(0, forKey: .appOpenCount)
                }
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

extension PlayViewModelImpl {

    private func applyNowPlayItem() {
        twitterPostContent = createNewPostCotent(service: .twitter)
        mastodonPostContent = createNewPostCotent(service: .mastodon)
        autoPostControl(twitter: twitterPostContent, mastodon: mastodonPostContent)
    }

    /* 再生されている曲が変わるたびに新しく生成 */
    private func createNewPostCotent(service: Service) -> PostContent {
        guard let item = _nowPlayingItem.value else {
            return PostContent(postMessage: "", shareImage: nil, songTitle: "", artistName: "", service: service, item: nil)
        }
        var postText = UserDefaults.string(forKey: service.postTextFormatUserDefaultsKey)!

        let title = item.title ?? "不明なタイトル"
        let artist = item.artist ?? "不明なアーティスト"
        let album = item.albumTitle ?? "不明なアルバム"
        postText = postText.replacingOccurrences(of: "__songtitle__", with: title)
        postText = postText.replacingOccurrences(of: "__artist__", with: artist)
        postText = postText.replacingOccurrences(of: "__album__", with: album)

        let shareImage = getShareImage(service: service, item: item)

        return PostContent(postMessage: postText, shareImage: shareImage, songTitle: title, artistName: artist, service: service, item: item)
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
        guard UserDefaults.bool(forKey: .isAutoTweetPurchase) && UserDefaults.bool(forKey: .isAutoTweet),
            let user = User.getDefaultUser(service: .twitter),
            let secret = user.secretCredentials.first else { return }
        if let shareImage = content.shareImage, let data = shareImage.pngData() {
            tweetStatusAction.inputs.onNext((secret, content.postMessage, data))
            Analytics.AutoPost.withImageTweet(content)
        } else {
            tweetStatusAction.inputs.onNext((secret, content.postMessage, nil))
            Analytics.AutoPost.textOnlyTweet(content)
        }
    }

    private func postMastodon(_ content: PostContent) {
        guard UserDefaults.bool(forKey: .isMastodonAutoToot),
            let user = User.getDefaultUser(service: .mastodon),
            let secret = user.secretCredentials.first else { return }
        if let shareImage = content.shareImage, let data = shareImage.pngData() {
            tootUploadMediaAction.inputs.onNext((secret, data))
            Analytics.AutoPost.withImageToot(content)
        } else {
            tootStatusAction.inputs.onNext((secret, content.postMessage, nil))
            Analytics.AutoPost.textOnlyToot(content)
        }
    }
}

// MARK: - PlayViewModelInput

extension PlayViewModelImpl: PlayViewModelInput {}

// MARK: - PlayViewModelOutput

extension PlayViewModelImpl: PlayViewModelOutput {

    var nowPlayingItem: SharedSequence<DriverSharingStrategy, MPMediaItem> {
        return _nowPlayingItem
            .compactMap { $0 }
            .do(onNext: { [weak self] (_) in
                self?.applyNowPlayItem()
            })
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorDriveWith: .empty())
    }

    var playButtonImage: SharedSequence<DriverSharingStrategy, UIImage?> {
        return playStateTrigger
            .map { $0 ? R.image.pause() : R.image.play() }
            .asDriver(onErrorJustReturn: nil)
    }

    var scale: SharedSequence<DriverSharingStrategy, CGAffineTransform> {
        return playStateTrigger
            .map { $0 ? .identity : .init(scaleX: 0.9, y: 0.9) }
            .asDriver(onErrorJustReturn: .identity)
    }

    var postContent: SharedSequence<DriverSharingStrategy, PostContent> {
        return _postContent.observeOn(MainScheduler.instance).asDriver(onErrorDriveWith: .empty())
    }

    var requestDenied: Observable<Void> {
        return _requestDenied
            .observeOn(MainScheduler.instance)
            .do(onNext: {
                Feeder.Notification(.warning).notificationOccurred()
            })
            .asObservable()
    }
}
