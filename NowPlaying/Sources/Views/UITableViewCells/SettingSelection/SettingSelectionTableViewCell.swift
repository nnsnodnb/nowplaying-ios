//
//  SettingSelectionTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

final class SettingSelectionTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!

    func configure(selection: TwitterSettingViewController.Item.Selection) {
        // タイトル
        titleLabel.text = selection.title
    }
}
