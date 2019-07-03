//
//  AccountManageTableViewCell.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Nuke
import UIKit

final class AccountManageTableViewCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var screenNameLabel: UILabel!

    var user: User? {
        didSet {
            if let iconURL = user?.iconURL {
                loadImage(with: iconURL, into: iconImageView)
            }
            usernameLabel.text = user?.name
            screenNameLabel.text = user?.screenName
        }
    }

    override func prepareForReuse() {
        iconImageView.image = nil
        super.prepareForReuse()
    }
}
