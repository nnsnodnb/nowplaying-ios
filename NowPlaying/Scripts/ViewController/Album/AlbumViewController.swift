//
//  AlbumViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    fileprivate let audioPlayer = AVAudioPlayer()

    fileprivate var albums = [MPMediaItemCollection]()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        createAlbums()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private method

    fileprivate func createAlbums() {
        if let collections = MPMediaQuery.albums().collections {
            albums = collections
        }
    }

    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 97
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName: "AlbumTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "AlbumCell")
    }
}

// MARK: - UITableViewDataSource

extension AlbumViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumTableViewCell
        cell.setConfigure(album: albums[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AlbumViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumDetailViewController = AlbumDetailViewController()
        albumDetailViewController.album = albums[indexPath.row]
        navigationController?.pushViewController(albumDetailViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
