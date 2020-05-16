//
//  NowPlayingCore.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/16.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import MediaPlayer
import RxCocoa
import RxSwift
import SwifteriOS
import UIKit

protocol NowPlayingCoreType {}

class NowPlayingCore: NowPlayingCoreType {

    var autoPostEnabled: Observable<Bool> { fatalError("Please override") }

    private let disposeBag = DisposeBag()

    init() {
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlayback().disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .withLatestFrom(autoPostEnabled) { ($0, $1) }
            .filter { $1 }
            .map { $0.0 }
            .compactMap { $0.object as? MPMusicPlayerController }
            .compactMap { $0.nowPlayingItem }
            .distinctUntilChanged()
            .subscribe(onNext: {
                print(#file, #line, $0.title ?? "")
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - TwitterNowPlayingCore

final class TwitterNowPlayingCore: NowPlayingCore {

    override var autoPostEnabled: Observable<Bool> {
        return Observable.combineLatest(
            UserDefaults.standard.rx.change(type: Bool.self, key: .isAutoTweetPurchase),
            UserDefaults.standard.rx.change(type: Bool.self, key: .isAutoTweet)
        ) { ($0 ?? false, $1 ?? false) }
            .map { $0 && $1 }
    }

    private let disposeBag = DisposeBag()

    private lazy var postTweetAction: Action<(SecretCredential, String, Data?), JSON> = .init {
        return SwifterRequest(secretCredential: $0.0).rx.postTweet(status: $0.1, media: $0.2)
    }
}

// MARK: - MastodonNowPlayingCore

final class MastodonNowPlayingCore: NowPlayingCore {

    override var autoPostEnabled: Observable<Bool> {
        return UserDefaults.standard.rx.change(type: Bool.self, key: .isMastodonAutoToot).map { $0 ?? false }
    }
}
