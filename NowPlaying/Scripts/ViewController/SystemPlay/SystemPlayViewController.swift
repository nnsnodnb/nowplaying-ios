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

    fileprivate let playViewController = PlayViewController()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        playViewController.albumTitle = "アルバムタイトル"
        playViewController.view.frame = CGRect(origin: CGPoint(x: 0, y : 0),
                                               size: CGSize(width: view.frame.width, height: view.frame.height))
        addChildViewController(playViewController)
        view.addSubview(playViewController.view)
        playViewController.didMove(toParentViewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let item = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem {
            playViewController.song = item
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
