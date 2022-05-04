//
//  SettingTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import SFSafeSymbols
import UIKit

protocol SettingTableViewCellItemType {
    var image: UIImage? { get }
    var title: String { get }
}

final class SettingTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
    }

    func configure(item: SettingTableViewCellItemType) {
        // 画像
        iconImageView.isHidden = item.image == nil
        iconImageView.image = item.image
        // テキスト
        titleLabel.text = item.title
    }
}
