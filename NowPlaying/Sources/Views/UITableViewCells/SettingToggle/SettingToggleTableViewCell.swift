//
//  SettingToggleTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

protocol SettingToggleTableViewCellItemType {
    var title: String { get }
}

final class SettingToggleTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var toggleSwitch: UISwitch!

    func configure(item: SettingToggleTableViewCellItemType) {
        // テキスト
        titleLabel.text = item.title
    }
}
