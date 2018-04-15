//
//  SystemPlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/20.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer

class SystemPlayViewController: UIViewController {

    private let playViewController = PlayViewController()
    private let player = MPMusicPlayerController.systemMusicPlayer

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        playViewController.albumTitle = "アルバムタイトル"
        playViewController.view.frame = CGRect(origin: CGPoint(x: 0, y : 0),
                                               size: CGSize(width: view.frame.width, height: view.frame.height))
        addChildViewController(playViewController)
        view.addSubview(playViewController.view)
        playViewController.didMove(toParentViewController: self)
        setupNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.beginGeneratingPlaybackNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPlayViewControllerItem()
        setupAccessMusicLibrary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil
        )
        player.endGeneratingPlaybackNotifications()
        MPMediaLibrary.default().endGeneratingLibraryChangeNotifications()
    }

    // MARK: - Private method

    private func setupAccessMusicLibrary() {
        MPMediaLibrary.default().beginGeneratingLibraryChangeNotifications()
        MPMediaLibrary.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.setupPlayViewControllerItem()
                }
            case .denied:
                self.showRequestDeniedAlert()
            case .notDetermined, .restricted:
                break
            }
        }
    }

    private func setupNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(musicNotification(_:)),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil
        )
    }

    private func setupPlayViewControllerItem(isNotification: Bool=false) {
        if let item = player.nowPlayingItem {
            playViewController.song = item
            playViewController.isNotification = isNotification
        }
    }

    private func showRequestDeniedAlert() {
        let alert = UIAlertController(title: "アプリを使用するには\n許可が必要です", message: "設定しますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "設定画面へ", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Notification target

    @objc func musicNotification(_ notification: Notification) {
        setupPlayViewControllerItem(isNotification: true)
    }
}
