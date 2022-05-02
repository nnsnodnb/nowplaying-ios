//
//  MPMusicPlayerController+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/05.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import MediaPlayer
import RxCocoa
import RxSwift

extension MPMusicPlayerController {

    func beginGeneratingPlayback() -> Disposable {
        beginGeneratingPlaybackNotifications()
        return Disposables.create { [weak self] in
            self?.endGeneratingPlaybackNotifications()
        }
    }

    var playing: Binder<Bool> {
        return .init(self) { player, isPlaying in
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
        }
    }

    var skipToPreviousItem: Binder<Void> {
        return .init(self) { player, _ in
            player.skipToPreviousItem()
        }
    }

    var skipToNextItem: Binder<Void> {
        return .init(self) { player, _ in
            player.skipToNextItem()
        }
    }
}
