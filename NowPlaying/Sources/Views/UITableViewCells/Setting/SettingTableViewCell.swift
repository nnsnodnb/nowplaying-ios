//
//  SettingTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import SFSafeSymbols
import UIKit

final class SettingTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
    }

    func configure(item: SettingViewController.Item) {
        // 画像
        let image: UIImage
        switch item {
        case let .socialType(socialType):
            image = socialType.image
        case let .link(link):
            switch link {
            case .developer:
                image = .init(systemSymbol: .personFill).withTintColor(.systemIndigo, renderingMode: .alwaysOriginal)
            case .github:
                image = Asset.Assets.icGithub.image
            case .contact:
                image = .init(systemSymbol: .exclamationmarkBubbleFill).withTintColor(.systemGreen,
                                                                                      renderingMode: .alwaysOriginal)
            }
        case .removeAdMob:
            image = Asset.Assets.icPackage.image
        case .review:
            image = .init(systemSymbol: .pencilCircleFill).withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        }
        iconImageView.image = image
        // テキスト
        titleLabel.text = item.title
    }
}
