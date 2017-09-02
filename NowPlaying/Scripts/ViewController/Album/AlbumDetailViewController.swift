//
//  AlbumDetailViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer
import ExtensionCollection

class AlbumDetailViewController: UIViewController {

    @IBOutlet weak var topMargin: NSLayoutConstraint!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumArtistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var album: MPMediaItemCollection?
    var singles = [MPMediaItem]()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setLabel()
        createSongData()
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
        if let title = album?.representativeItem?.albumTitle {
            self.title = title
        } else {
            title = "不明なアルバム"
        }
    }

    fileprivate func setLabel() {
        albumTitleLabel.text = album!.representativeItem?.albumTitle
        albumArtistLabel.text = album!.representativeItem?.albumArtist
        if let artwork = album!.representativeItem?.artwork {
            let artworkImage = artwork.image(at: artworkImageView.frame.size)
            artworkImageView.image = artworkImage
        }
        genreLabel.text = album!.representativeItem?.genre

        guard let releaseDate = album?.representativeItem?.releaseDate else {
            releaseYearLabel.isHidden = true
            return
        }
        let yearFormatter = DateFormatter.withOutDateFormat()
        yearFormatter.dateFormat = "yyyy"
        releaseYearLabel.text = "\(yearFormatter.string(from: releaseDate))年"
    }

    fileprivate func createSongData() {
        guard album?.items != nil else {
            return
        }
        singles = album!.items
    }

    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SongTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "SongCell")
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource

extension AlbumDetailViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return singles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongTableViewCell
        let title = singles[indexPath.row].value(forProperty: MPMediaItemPropertyTitle) as! String
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.nameLabel.text = title

        return cell
    }
}

// MARK: - UITableViewDelegate

extension AlbumDetailViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
