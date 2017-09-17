//
//  AudioManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/17.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import AVFoundation
import MediaPlayer

class AudioManager: NSObject {

    var currentAlbum: [MPMediaItem]?
    var currentNumberOfDisc: Int?

    fileprivate var audioPlayer: AVAudioPlayer!

    static let shared = AudioManager()

    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }

    func play(url: URL?=nil, album: [MPMediaItem]?=nil, number: Int?=nil) {
        guard url != nil else {
            return
        }
        try! audioPlayer = AVAudioPlayer(contentsOf: url!)
        audioPlayer.delegate = self
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! AVAudioSession.sharedInstance().setActive(true)
        audioPlayer.play()
        if album == nil, number != nil {
            return
        }
        currentAlbum = album
        currentNumberOfDisc = number
    }

    func pause() {
        audioPlayer.pause()
    }

    func next() {
        guard let number = currentNumberOfDisc, let album = currentAlbum, number != (album.count - 1) else {
            return
        }
        currentNumberOfDisc! += 1
        pause()
        play(url: album[currentNumberOfDisc!].value(forProperty: MPMediaItemPropertyAssetURL) as? URL,
             album: album,
             number: currentNumberOfDisc)
    }

    func previous() {
        guard let number = currentNumberOfDisc, let album = currentAlbum, number != 0 else {
            return
        }
        // TODO: - 1秒以内の再生なら曲の始めに戻す
        currentNumberOfDisc! -= 1
        pause()
        play(url: album[currentNumberOfDisc!].value(forProperty: MPMediaItemPropertyAssetURL) as? URL,
             album: album,
             number: currentNumberOfDisc!)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager : AVAudioPlayerDelegate {


}
