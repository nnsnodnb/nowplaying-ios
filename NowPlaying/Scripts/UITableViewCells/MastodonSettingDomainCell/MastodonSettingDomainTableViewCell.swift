//
//  MastodonSettingDomainTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/26.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Eureka
import UIKit

final class MastodonSettingDomainCell: Cell<String>, CellType {

    @IBOutlet weak var domainLabel: UILabel!

    override func update() {
        super.update()
        domainLabel.text = row.value
    }
}

final class MastodonSettingDomainRow: Row<MastodonSettingDomainCell>, RowType {

    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MastodonSettingDomainCell>(nibName: R.nib.mastodonSettingDomainTableViewCell.name)
    }
}
