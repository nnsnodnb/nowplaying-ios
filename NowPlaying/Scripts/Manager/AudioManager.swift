//
//  AudioManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/17.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import AVFoundation

class AudioManager: NSObject {

    var audioPlayer: AVAudioPlayer!

    static let shared = AudioManager()
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager : AVAudioPlayerDelegate {


}
