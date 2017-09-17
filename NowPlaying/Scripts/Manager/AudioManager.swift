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
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url!)
            audioPlayer.delegate = self
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)

            audioPlayer.play()
        } catch {
            return
        }
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
        guard let number = currentNumberOfDisc, let album = currentAlbum else {
            return
        }
        if number == album.count - 1 {
            currentNumberOfDisc = 0
        } else {
            currentNumberOfDisc! += 1
        }
        pause()
        play(url: album[currentNumberOfDisc!].value(forProperty: MPMediaItemPropertyAssetURL) as? URL,
             album: album,
             number: currentNumberOfDisc)
    }

    func previous() {
        guard let album = currentAlbum, currentNumberOfDisc != nil else {
            return
        }
        if audioPlayer.currentTime < 2.0 {
            currentNumberOfDisc! -= 1
        }
        if currentNumberOfDisc! == -1 {
            currentNumberOfDisc = album.count - 1
        }
        pause()
        play(url: album[currentNumberOfDisc!].value(forProperty: MPMediaItemPropertyAssetURL) as? URL,
             album: album,
             number: currentNumberOfDisc!)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager : AVAudioPlayerDelegate {


}
