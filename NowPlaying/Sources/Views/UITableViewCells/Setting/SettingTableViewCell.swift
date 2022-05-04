//
//  SettingTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

final class SettingTableViewCell: UITableViewCell {
    func configure(item: SettingViewController.Item) {
        textLabel?.text = item.title
    }
}
