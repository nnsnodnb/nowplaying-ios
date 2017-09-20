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

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    fileprivate func setup() {
        setupNavigation()
    }

    fileprivate func setupNavigation() {
        guard navigationController != nil else {
            return
        }
    }
}
