//
//  SettingToggleTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

final class SettingToggleTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var toggleSwitch: UISwitch!

    func configure(item: SettingProviderViewController.Item) {
        // テキスト
        titleLabel.text = item.title
    }
}
