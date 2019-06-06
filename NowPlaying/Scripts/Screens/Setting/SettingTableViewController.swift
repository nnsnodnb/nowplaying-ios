//
//  SettingTableViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit

final class SettingTableViewController: UITableViewController {

    private struct DataSource {
        let sns: [SNS] = SNS.allCases
        let about: [About] = About.allCases
    }

    private enum Section {
        case sns([SNS])
        case about([About])

        var numberOfRowsInSection: Int {
            switch self {
            case .sns(let rows):
                return rows.count
            case .about(let rows):
                return rows.count
            }
        }
    }

    private enum SNS: CaseIterable {
        case twitter
        case mastodon
    }

    private enum About: CaseIterable {
        case developer
        case github
        case bugReport
        case review
    }

    private lazy var dataSource: [Section] = [.sns(SNS.allCases), .about(About.allCases)]

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UITableViewDataSource

extension SettingTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].numberOfRowsInSection
    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
}
