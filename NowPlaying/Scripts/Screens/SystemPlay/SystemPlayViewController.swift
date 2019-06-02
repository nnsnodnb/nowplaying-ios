//
//  SystemPlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/20.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer
import SnapKit

class SystemPlayViewController: UIViewController {

    private let playViewController = PlayViewController()
    private let player = MPMusicPlayerController.systemMusicPlayer

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        playViewController.albumTitle = "アルバムタイトル"
        addChild(playViewController)
        view.addSubview(playViewController.view)
        playViewController.view.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        playViewController.didMove(toParent: self)
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
            @unknown default:
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
        alert.addAction(UIAlertAction(title: "設定画面へ", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        })
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Notification target

    @objc private func musicNotification(_ notification: Notification) {
        setupPlayViewControllerItem(isNotification: true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
