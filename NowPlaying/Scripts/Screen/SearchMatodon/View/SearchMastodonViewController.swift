//
//  SearchMastodonViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class SearchMastodonViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.register(R.nib.searchMastodonTableViewCell)
            tableView.tableHeaderView = searchController.searchBar

            tableView.rx.itemSelected
                .subscribe(onNext: { [unowned self] in
                    self.tableView.deselectRow(at: $0, animated: true)
                })
                .disposed(by: disposeBag)

            tableView.rx.modelSelected(Instance.self).bind(to: viewModel.input.selectInstance).disposed(by: disposeBag)

            searchController.searchBar.rx.cancelButtonClicked
                .bind(to: viewModel.input.cancelButtonClicked).disposed(by: disposeBag)

            searchController.searchBar.rx.text.orEmpty
                .distinctUntilChanged()
                .bind(to: viewModel.input.searchText)
                .disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()

    private(set) var viewModel: SearchMastodonViewModelType!

    private lazy var configureCell: RxTableViewSectionedAnimatedDataSource<InstanceAnimatableSectionModel>.ConfigureCell = {
        let cell = $1.dequeueReusableCell(withIdentifier: R.nib.searchMastodonTableViewCell, for: $2)!
        cell.instance = $3
        return cell
    }
    private lazy var dataSource: RxTableViewSectionedAnimatedDataSource<InstanceAnimatableSectionModel> = {
        return .init(configureCell: configureCell)
    }()
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "例: mstdn.jp"
        searchController.searchBar.searchBarStyle = .default
        searchController.obscuresBackgroundDuringPresentation = false
        return searchController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.output.dataSource.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
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
