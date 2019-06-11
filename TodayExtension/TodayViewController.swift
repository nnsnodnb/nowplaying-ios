//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Oka Yuya on 2018/04/11.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import MediaPlayer
import NotificationCenter
import RxCocoa
import RxSwift
import UIKit

final class TodayViewController: UIViewController {

    @IBOutlet private weak var artworkImageButton: UIButton! {
        didSet {
            artworkImageButton.rx.tap
                .subscribe(onNext: { [unowned self] (_) in
                    guard let url = URL(string: "nowplaying-ios-nnsnodnb://") else { return }
                    self.extensionContext?.open(url, completionHandler: nil)
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var songNameLabel: UILabel!
    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var deniedView: UIView!

    private let disposeBag = DisposeBag()
    private let player = MPMusicPlayerController.systemMusicPlayer
    private let nowPlayingItem = PublishRelay<MPMediaItem?>()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .subscribe(onNext: { [weak self] (notification) in
                guard let player = notification.object as? MPMusicPlayerController else { return }
                self?.nowPlayingItem.accept(player.nowPlayingItem)
            })
            .disposed(by: disposeBag)

        nowPlayingItem.asObservable()
            .subscribe(onNext: { [weak self] (item) in
                guard let wself = self else { return }
                let image = item?.artwork?.image(at: wself.artworkImageButton.frame.size)
                wself.artworkImageButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
                wself.songNameLabel.text = item?.title
                wself.artistNameLabel.text = item?.artist
            })
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.beginGeneratingPlaybackNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAccessMusicLibrary()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.endGeneratingPlaybackNotifications()
    }

    // MARK: - Private method

    private func setupAccessMusicLibrary() {
        MPMediaLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async { [unowned self] in
                switch status {
                case .authorized:
                    // 取得までに時間がかかるので遅延処理
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.nowPlayingItem.accept(MPMusicPlayerController.systemMusicPlayer.nowPlayingItem)
                        self?.deniedView.isHidden = true
                    }
                case .denied:
                    self.deniedView.isHidden = false
                case .notDetermined, .restricted:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
}

// MARK: - NCWidgetProviding

extension TodayViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(.newData)
    }
}
