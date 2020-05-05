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

    var isPlay: Binder<Bool> {
        return .init(self) { (player, isPlay) in
            if isPlay {
                player.play()
            } else {
                player.pause()
            }
        }
    }

    var skipToPreviousItem: Binder<Void> {
        return .init(self) { (player, _) in
            player.skipToPreviousItem()
        }
    }

    var skipToNextItem: Binder<Void> {
        return .init(self) { (player, _) in
            player.skipToNextItem()
        }
    }
}
