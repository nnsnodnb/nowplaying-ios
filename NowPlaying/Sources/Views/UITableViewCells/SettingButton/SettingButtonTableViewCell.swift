//
//  SettingButtonTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

protocol SettingButtonTableViewCellItemType {
    var title: String { get }
}

final class SettingButtonTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var titleLabel: UILabel!

    func configure(item: SettingButtonTableViewCellItemType) {
        // テキスト
        titleLabel.text = item.title
    }
}
