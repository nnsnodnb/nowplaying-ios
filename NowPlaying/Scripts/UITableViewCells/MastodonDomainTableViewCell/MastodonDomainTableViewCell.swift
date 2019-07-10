//
//  MastodonDomainTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/26.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit

final class MastodonDomainTableViewCell: UITableViewCell {

    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var instanceNameLabel: UILabel!
    @IBOutlet private weak var instanceDescriptionLabel: UILabel!

    var instance: Instance! {
        didSet {
            thumbnailImageView.setImage(with: instance.thumbnailURL)
            instanceNameLabel.text = instance.name
            instanceDescriptionLabel.text = instance.info?.shortDescription
        }
    }
}
