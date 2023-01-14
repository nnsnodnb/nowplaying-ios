//
//  SettingButtonTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

final class SettingButtonTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var titleLabel: UILabel!

    func configure(button: SettingProviderViewController.Item.Button) {
        // テキスト
        titleLabel.text = button.title
    }
}
