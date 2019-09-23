//
//  UITableView+Changeset.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/09/24.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit
import RxRealm

extension UITableView {

    func applyChangeset(_ changes: RealmChangeset) {
        beginUpdates()
        deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        endUpdates()
    }
}
