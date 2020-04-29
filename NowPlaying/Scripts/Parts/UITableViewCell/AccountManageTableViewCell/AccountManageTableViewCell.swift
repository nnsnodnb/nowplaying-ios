//
//  AccountManageTableViewCell.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class AccountManageTableViewCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var defaultAccountStartImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var screenNameLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!

    var user: User! {
        didSet {
            iconImageView.setImage(with: user.iconURL)
            defaultAccountStartImageView.isHidden = !user.isDefault
            usernameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenName)"
            domainLabel.isHidden = user.isTwitetrUser
            guard let secret = user.secretCredentials.first else { return }
            domainLabel.text = secret.domainName
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        iconImageView.image = nil
        domainLabel.text = nil
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
