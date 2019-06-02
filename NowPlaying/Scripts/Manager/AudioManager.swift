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

    var currentAlbum: MPMediaItemCollection?
    var currentNumberOfDisc: Int?

    private var audioPlayer: AVAudioPlayer!
    private var singles: [MPMediaItem]?

    static let shared = AudioManager()

    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }

    var duration: TimeInterval {
        return audioPlayer.duration
    }

    var currentTime: TimeInterval {
        return audioPlayer.currentTime
    }

    @discardableResult
    func play(url: URL?=nil, album: [MPMediaItem]?=nil, number: Int?=nil) -> MPMediaItem? {
        guard url != nil else {
            audioPlayer.play()
            return nil
        }
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url!)
            audioPlayer.delegate = self
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playAndRecord)))
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)

            audioPlayer.play()
        } catch {
            return nil
        }
        if album == nil, number != nil {
            return nil
        }
        singles = album
        currentNumberOfDisc = number

        notifyNowPlaying(song: singles![currentNumberOfDisc!])

        UIApplication.shared.beginReceivingRemoteControlEvents()

        return singles![currentNumberOfDisc!]
    }

    @discardableResult
    func pause() -> MPMediaItem {
        audioPlayer.pause()

        return singles![currentNumberOfDisc!]
    }

    @discardableResult
    func next() -> MPMediaItem? {
        guard let number = currentNumberOfDisc, let singles = singles else {
            return nil
        }
        if number == singles.count - 1 {
            currentNumberOfDisc = 0
        } else {
            currentNumberOfDisc! += 1
        }
        pause()
        play(url: singles[currentNumberOfDisc!].value(forProperty: MPMediaItemPropertyAssetURL) as? URL,
             album: singles,
             number: currentNumberOfDisc)

        return singles[currentNumberOfDisc!]
    }

    @discardableResult
    func previous() -> MPMediaItem? {
        guard let singles = singles, currentNumberOfDisc != nil else {
            return nil
        }
        if audioPlayer.currentTime < 2.0 {
            currentNumberOfDisc! -= 1
        }
        if currentNumberOfDisc! == -1 {
            currentNumberOfDisc = singles.count - 1
        }
        pause()
        play(url: singles[currentNumberOfDisc!].value(forProperty: MPMediaItemPropertyAssetURL) as? URL,
             album: singles,
             number: currentNumberOfDisc!)

        return singles[currentNumberOfDisc!]
    }

    private func notifyNowPlaying(song: MPMediaItem) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: song.value(forProperty: MPMediaItemPropertyTitle) ?? "",
            MPMediaItemPropertyAlbumTitle: song.value(forProperty: MPMediaItemPropertyAlbumTitle) ?? "",
            MPMediaItemPropertyArtist: song.value(forProperty: MPMediaItemPropertyArtist) ?? "",
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: AudioManager.shared.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: AudioManager.shared.currentTime
        ]
        if let artwork = currentAlbum?.representativeItem?.artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager : AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        next()
    }

    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        pause()
    }

    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        play()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
