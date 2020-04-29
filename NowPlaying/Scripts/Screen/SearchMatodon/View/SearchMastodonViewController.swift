//
//  SearchMastodonViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class SearchMastodonViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }

    private(set) var viewModel: SearchMastodonViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SearchMastodonViewController {

    struct Dependency {
        let viewModel: SearchMastodonViewModelType
    }

    class func makeInstance() -> SearchMastodonViewController {
        let viewController = SearchMastodonViewController()
        let router = SearchMastodonRouter(view: viewController)
        let viewModel = SearchMastodonViewModel(router: router)
        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}

// MARK: - SearchMastodonViewer

extension SearchMastodonViewController: SearchMastodonViewer {}
