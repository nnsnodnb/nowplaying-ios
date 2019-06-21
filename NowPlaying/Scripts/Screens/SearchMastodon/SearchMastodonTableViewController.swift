//
//  SearchMastodonTableViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/19.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Nuke
import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

final class SearchMastodonTableViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    private let searchBar: UISearchBar
    private let viewModel: SearchMastodonTableViewModelType

    // MARK: - Initializer

    init() {
        searchBar = UISearchBar()
        searchBar.placeholder = "mstdn.jp"
        let inputs = SearchMastodonTableViewModelInput(searchBarText: searchBar.rx.text.asObservable())
        viewModel = SearchMastodonTableViewModel(inputs: inputs)
        super.init(nibName: R.nib.searchMastodonTableViewController.name, bundle: R.nib.searchMastodonTableViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.indexPathsForSelectedRows?.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }

        viewModel.outputs.isLoading
            .observeOn(MainScheduler.instance)
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)

        viewModel.outputs.error
            .subscribe(onNext: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.mastodonInstances
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items) { _, _, instance in
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "subtitle")
                cell.textLabel?.text = "\(instance.name)"
                cell.detailTextLabel?.textColor = .lightGray
                cell.detailTextLabel?.text = instance.info?.shortDescription
                guard let imageView = cell.imageView else { return cell }
                loadImage(with: instance.thumbnailURL, into: imageView)
                imageView.contentMode = .scaleAspectFit
                return cell
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension SearchMastodonTableViewController {
}

// MARK: - UITableViewDelegate

extension SearchMastodonTableViewController {

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
}
