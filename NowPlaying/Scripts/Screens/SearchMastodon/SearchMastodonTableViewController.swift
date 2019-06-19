//
//  SearchMastodonTableViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/19.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit
import RxSwift

final class SearchMastodonTableViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: SearchMastodonTableViewModelType

    // MARK: - Initializer

    init() {
        viewModel = SearchMastodonTableViewModel()
        super.init(nibName: R.nib.searchMastodonTableViewController.name, bundle: R.nib.searchMastodonTableViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UITableViewDataSource

extension SearchMastodonTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

// MARK: - UITableViewDelegate

extension SearchMastodonTableViewController {

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchBar = UISearchBar()
        searchBar.placeholder = "mstdn.jp"
        return searchBar
    }
}
