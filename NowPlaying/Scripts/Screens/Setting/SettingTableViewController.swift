//
//  SettingTableViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit

final class SettingTableViewController: UITableViewController {

    // MARK: - Life cycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UITableViewDataSource

extension SettingTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
