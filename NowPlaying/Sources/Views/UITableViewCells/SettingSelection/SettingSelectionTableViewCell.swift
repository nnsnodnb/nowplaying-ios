//
//  SettingSelectionTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

protocol SettingSelectionTableViewCellItemType {
    var title: String { get }
}

final class SettingSelectionTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!

    func configure(item: SettingSelectionTableViewCellItemType) {
        // タイトル
        titleLabel.text = item.title
    }
}
