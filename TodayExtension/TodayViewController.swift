//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Oka Yuya on 2018/04/11.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer
import NotificationCenter

class TodayViewController: UIViewController {

    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var deniedView: UIView!

    private let player = MPMusicPlayerController.systemMusicPlayer

    private var nowPlayingItem: MPMediaItem? {
        didSet {
            artworkImageView.image = nowPlayingItem?.artwork?.image(at: artworkImageView.frame.size)
            songNameLabel.text = nowPlayingItem?.title
            artistNameLabel.text = nowPlayingItem?.artist
        }
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupNowPlaying()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.beginGeneratingPlaybackNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAccessMusicLibrary()
        setupPlayViewControllerItem()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.endGeneratingPlaybackNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        MPMediaLibrary.default().endGeneratingLibraryChangeNotifications()
    }

    // MARK: - Private method

    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(musicNotification(_:)),
                                               name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }

    private func setupNowPlaying() {
        guard MPMusicPlayerController.systemMusicPlayer.playbackState == .playing else { return }
    }

    private func setupPlayViewControllerItem() {
        if let item = player.nowPlayingItem {
            nowPlayingItem = item
        }
    }

    private func setupAccessMusicLibrary() {
        MPMediaLibrary.default().beginGeneratingLibraryChangeNotifications()
        MPMediaLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async { [unowned self] in
                switch status {
                case .authorized:
                    // 取得までに時間がかかるので遅延処理
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.setupPlayViewControllerItem()
                        self.deniedView.isHidden = true
                    }
                case .denied:
                    self.deniedView.isHidden = false
                case .notDetermined, .restricted:
                    break
                }
            }
        }
    }
}

// MARK: - Notification target

extension TodayViewController {

    @objc private func musicNotification(_ notification: Notification) {
        setupPlayViewControllerItem()
    }
}

// MARK: - NCWidgetProviding

extension TodayViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
}
