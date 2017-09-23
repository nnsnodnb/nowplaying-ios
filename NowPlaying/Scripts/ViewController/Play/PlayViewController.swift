//
//  PlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/20.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!

    var albumTitle: String! {
        didSet {
            title = albumTitle
        }
    }
    var song: MPMediaItem? {
        didSet {
            artworkImageView.image = song?.artwork?.image(at: artworkImageView.frame.size)
            songNameLabel.text = song?.title
        }
    }

    fileprivate var isPlay = MPMusicPlayerController.systemMusicPlayer().playbackState == .playing

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    fileprivate func setup() {
        setupNavigation()
        setupView()
    }

    fileprivate func setupNavigation() {
        guard navigationController != nil else {
            return
        }
    }

    fileprivate func setupView() {
        songNameLabel.text = nil
    }

    // MARK: - IBAction

    @IBAction func onTapPreviousButton(_ sender: Any) {
        MPMusicPlayerController.systemMusicPlayer().skipToPreviousItem()
    }

    @IBAction func onTapPlayButton(_ sender: Any) {
        if isPlay {
            MPMusicPlayerController.systemMusicPlayer().pause()
        } else {
            MPMusicPlayerController.systemMusicPlayer().play()
        }
        isPlay = !isPlay
    }

    @IBAction func onTapNextButton(_ sender: Any) {
        MPMusicPlayerController.systemMusicPlayer().skipToNextItem()
    }

    @IBAction func onTapGearButton(_ sender: Any) {
        let settingViewController = SettingViewController()
        let navi = UINavigationController(rootViewController: settingViewController)
        present(navi, animated: true, completion: nil)
    }

    @IBAction func onTapTwitterButton(_ sender: Any) {
        let tweetViewController = TweetViewController()
        tweetViewController.tweetText = "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying"
        tweetViewController.shareImage = artworkImageView.image
        let navi = UINavigationController(rootViewController: tweetViewController)
        present(navi, animated: true, completion: nil)
    }
}
