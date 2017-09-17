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

    fileprivate var audioPlayer: AVAudioPlayer!
    fileprivate var singles: [MPMediaItem]?

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

    func remoteControlReceived(with event: UIEvent?) {
        switch event?.subtype {
        case .some(.remoteControlPlay):
            if let song = play() {
                notifyNowPlaying(song: song)
            }
        case .some(.remoteControlPause):
            let song = pause()
            notifyNowPlaying(song: song)
        case .some(.remoteControlNextTrack):
            let song = next()
            notifyNowPlaying(song: song!)
        case .some(.remoteControlPreviousTrack):
            let song = previous()
            notifyNowPlaying(song: song!)
        default:
            break
        }
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
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
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

    fileprivate func notifyNowPlaying(song: MPMediaItem) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo  = [
            MPMediaItemPropertyTitle: song.value(forProperty: MPMediaItemPropertyTitle) ?? "",
            MPMediaItemPropertyAlbumTitle: song.value(forProperty: MPMediaItemPropertyAlbumTitle) ?? "",
            MPMediaItemPropertyArtist: song.value(forProperty: MPMediaItemPropertyArtist) ?? "",
            MPMediaItemPropertyArtwork: currentAlbum?.representativeItem?.artwork ?? nil,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0,
            MPMediaItemPropertyPlaybackDuration: AudioManager.shared.duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: AudioManager.shared.currentTime
        ]
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager : AVAudioPlayerDelegate {


}
