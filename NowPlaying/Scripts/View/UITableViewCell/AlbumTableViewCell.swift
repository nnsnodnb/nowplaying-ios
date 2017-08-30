//
//  AlbumTableViewCell.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var jacketImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var albumArtistLabel: UILabel!

    fileprivate var album: MPMediaItemCollection?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setConfigure(album: MPMediaItemCollection) {
        self.album = album
        albumTitleLabel.text = album.representativeItem?.albumTitle
        albumArtistLabel.text = album.representativeItem?.albumArtist
        if let artwork = album.representativeItem?.artwork {
            let artworkImage = artwork.image(at: jacketImageView.frame.size)
            jacketImageView.image = artworkImage
        }
    }
}
