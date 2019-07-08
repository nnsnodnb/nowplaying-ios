//
//  AccountManageTableViewCell.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit

final class AccountManageTableViewCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var defaultAccountStarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var screenNameLabel: UILabel!
    @IBOutlet private weak var domainLabel: UILabel!

    private(set) var user: User! {
        didSet {
            iconImageView.setImage(with: user.iconURL)
            defaultAccountStarImageView.isHidden = !user.isDefault
            usernameLabel.text = user.name
            screenNameLabel.text = "@\(user.screenName)"
        }
    }
    private var secret: SecretCredential? {
        didSet {
            domainLabel.isHidden = secret == nil
            guard let secret = secret else { return }
            domainLabel.text = secret.domainName
        }
    }

    override func prepareForReuse() {
        iconImageView.image = nil
        super.prepareForReuse()
    }

    func configure(user: User, secret: SecretCredential?) {
        self.user = user
        self.secret = secret
    }
}
