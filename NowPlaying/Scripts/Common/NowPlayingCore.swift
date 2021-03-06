//
//  NowPlayingCore.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/16.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import MastodonKit
import MediaPlayer
import NotificationBanner
import RealmSwift
import RxCocoa
import RxSwift
import SwifteriOS
import UIKit

protocol NowPlayingCoreType {}

class NowPlayingCore: NowPlayingCoreType {

    var service: Service { fatalError("Please overrive") }
    var autoPostEnabled: Observable<Bool> { fatalError("Please override") }
    var postImageTypeKey: UserDefaults.Key { fatalError("Please override") }
    var nowPlayingItem: Observable<MPMediaItem> { return mediaItem.asObservable() }
    var isOnlyArtwork: Observable<Bool> { return attachmentImageType.map { $0 == "アートワークのみ" } }

    lazy var successBanner: NotificationBanner = {
        let banner = NotificationBanner(title: "\(service == .twitter ? "ツイート" : "トゥート")しました！", style: .success)
        banner.haptic = .none
        return banner
    }()

    private let disposeBag = DisposeBag()
    private let mediaItem: PublishRelay<MPMediaItem> = .init()

    private lazy var attachmentImageType: BehaviorRelay<String> = {
        return .init(value: UserDefaults.standard.string(forKey: postImageTypeKey)!)
    }()

    init() {
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlayback().disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .withLatestFrom(autoPostEnabled) { ($0, $1) }
            .filter { $1 }
            .map { $0.0 }
            .compactMap { $0.object as? MPMusicPlayerController }
            .compactMap { $0.nowPlayingItem }
            .distinctUntilChanged()
            .bind(to: mediaItem)
            .disposed(by: disposeBag)

        UserDefaults.standard.rx.change(type: String.self, key: postImageTypeKey)
            .compactMap { $0 }
            .bind(to: attachmentImageType)
            .disposed(by: disposeBag)
    }
}

// MARK: - TwitterNowPlayingCore

final class TwitterNowPlayingCore: NowPlayingCore {

    override var service: Service { return .twitter }
    override var autoPostEnabled: Observable<Bool> {
        return Observable.combineLatest(
            UserDefaults.standard.rx.change(type: Bool.self, key: .isAutoTweetPurchase),
            UserDefaults.standard.rx.change(type: Bool.self, key: .isAutoTweet)
        ) { ($0 ?? false, $1 ?? false) }
            .map { $0 && $1 }
    }
    override var postImageTypeKey: UserDefaults.Key { return .tweetWithImageType }

    private let disposeBag = DisposeBag()

    private lazy var postTweetAction: Action<(SecretCredential, String, Data?), JSON> = .init {
        return SwifterRequest(secretCredential: $0.0).rx.postTweet(status: $0.1, media: $0.2)
    }

    override init() {
        super.init()

        postTweetAction.executing.startWith(false)
            .skip(1)
            .subscribe(onNext: { [unowned self](isLoading) in
                NotificationCenter.default.post(name: .autoPostBannerNotification, object: isLoading,
                                                userInfo: ["service": self.service])
            })
            .disposed(by: disposeBag)

        nowPlayingItem
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .withLatestFrom(isOnlyArtwork) { ($0, $1) }
            .compactMap { (item, isOnlyArtwork) -> (SecretCredential, String, Data?)? in
                let realm = try! Realm(configuration: realmConfiguration)
                guard let user = realm.objects(User.self)
                    .filter("isDefault = %@ AND serviceType = %@", true, Service.twitter.rawValue).first,
                    let secret = user.secretCredentials.first else { return nil }

                let postText = Service.getPostText(.twitter, item: item)

                if UserDefaults.standard.bool(forKey: .isWithImage) {
                    let image: UIImage?
                    if isOnlyArtwork {
                        image = item.artwork?.image
                    } else {
                        image = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds).image {
                            AppDelegate.shared.window?.rootViewController?.view.layer.render(in: $0.cgContext)
                        }
                    }
                    return (secret, postText, image?.jpegData(compressionQuality: 1))
                } else {
                    return (secret, postText, nil)
                }
            }
            .bind(to: postTweetAction.inputs)
            .disposed(by: disposeBag)
    }
}

// MARK: - MastodonNowPlayingCore

final class MastodonNowPlayingCore: NowPlayingCore {

    override var service: Service { return .mastodon }
    override var autoPostEnabled: Observable<Bool> {
        return UserDefaults.standard.rx.change(type: Bool.self, key: .isMastodonAutoToot).map { $0 ?? false }
    }
    override var postImageTypeKey: UserDefaults.Key { return .tootWithImageType }

    private let disposeBag = DisposeBag()

    private lazy var postTootAction: Action<(SecretCredential, String, Data?), Status> = .init {
        return MastodonKitRequest(secret: $0.0).rx.postToot(status: $0.1, media: $0.2)
    }

    override init() {
        super.init()

        postTootAction.executing.startWith(false)
            .skip(1)
            .subscribe(onNext: { [unowned self](isLoading) in
                NotificationCenter.default.post(name: .autoPostBannerNotification, object: isLoading,
                                                userInfo: ["service": self.service])
            })
            .disposed(by: disposeBag)

        nowPlayingItem
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .withLatestFrom(isOnlyArtwork) { ($0, $1) }
            .compactMap { (item, isOnlyArtwork) -> (SecretCredential, String, Data?)? in
                let realm = try! Realm(configuration: realmConfiguration)
                guard let user = realm.objects(User.self)
                    .filter("isDefault = %@ AND serviceType = %@", true, Service.mastodon.rawValue).first,
                    let secret = user.secretCredentials.first else { return nil }

                let postText = Service.getPostText(.mastodon, item: item)
                if UserDefaults.standard.bool(forKey: .isMastodonWithImage) {
                    let image: UIImage?
                    if isOnlyArtwork {
                        image = item.artwork?.image
                    } else {
                        image = UIGraphicsImageRenderer(bounds: UIScreen.main.bounds).image {
                            AppDelegate.shared.window?.rootViewController?.view.layer.render(in: $0.cgContext)
                        }
                    }
                    return (secret, postText, image?.jpegData(compressionQuality: 1))
                } else {
                    return (secret, postText, nil)
                }
            }
            .bind(to: postTootAction.inputs)
            .disposed(by: disposeBag)
    }
}
