//
//  AlbumDetailViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumDetailViewController: UIViewController {

    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumArtistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var album: MPMediaItemCollection?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    fileprivate func setupNavigation() {
        guard navigationController != nil else {
            topMargin.constant = UIApplication.shared.statusBarFrame.height
            return
        }
        topMargin.constant += UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.size.height
    }

    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SongTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "SongCell")
    }
}

// MARK: - UITableViewDataSource

extension AlbumDetailViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AlbumDetailViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
