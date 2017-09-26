//
//  PlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/20.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer
import TwitterKit
import SVProgressHUD

class PlayViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

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
    var isNotification: Bool = false {
        didSet {
            if !isNotification {
                return
            }
            autoTweet()
        }
    }

    fileprivate let userDefaults = UserDefaults.standard

    fileprivate var isPlay: Bool = MPMusicPlayerController.systemMusicPlayer().playbackState == .playing {
        didSet {
            playButton.setImage(UIImage(named: isPlay ? "pause" : "play"), for: .normal)
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    fileprivate func setupNavigation() {
        guard navigationController != nil else {
            return
        }
    }

    fileprivate func setupView() {
        songNameLabel.text = nil
        isPlay = MPMusicPlayerController.systemMusicPlayer().playbackState == .playing
    }

    fileprivate func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    fileprivate func autoTweet() {
        if !userDefaults.bool(forKey: UserDefaultsKey.isAutoTweet.rawValue) || Twitter.sharedInstance().sessionStore.session() == nil {
            return
        }
        SVProgressHUD.show()
        let message = "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying"
        if let artwork = song?.artwork, userDefaults.bool(forKey: UserDefaultsKey.isWithImage.rawValue) {
            let image = artwork.image(at: artwork.bounds.size)
            TwitterClient.shared.client?.sendTweet(withText: message, image: image!) { (tweet, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showError(error: error!)
                }
            }
        } else {
            TwitterClient.shared.client?.sendTweet(withText: message) { [unowned self] (tweet, error) in
                SVProgressHUD.dismiss()
                if error != nil {
                    self.showError(error: error!)
                }
            }
        }
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
        if Twitter.sharedInstance().sessionStore.session() == nil {
            let alert = UIAlertController(title: nil, message: "設定からログインしてください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "閉じる", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let tweetViewController = TweetViewController()
        tweetViewController.tweetText = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem != nil ? "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying" : nil
        if let artwork = song?.artwork, userDefaults.bool(forKey: UserDefaultsKey.isWithImage.rawValue) {
            let image = artwork.image(at: artwork.bounds.size)
            tweetViewController.shareImage = image
        }
        let navi = UINavigationController(rootViewController: tweetViewController)
        present(navi, animated: true, completion: nil)
    }
}
