//
//  SearchMastodonTableViewCell.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class SearchMastodonTableViewCell: UITableViewCell {

    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var instanceNameLabel: UILabel!
    @IBOutlet private weak var instanceDescriptionLabel: UILabel!

    var instance: Instance? {
        didSet {
            guard let instance = instance else { return }
            if let url = instance.thumbnailURL {
                thumbnailImageView.setImage(with: url)
            }
            instanceNameLabel.text = instance.name
            instanceDescriptionLabel.text = instance.info?.shortDescription
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        instanceNameLabel.text = nil
        instanceDescriptionLabel.text = nil
    }
}
