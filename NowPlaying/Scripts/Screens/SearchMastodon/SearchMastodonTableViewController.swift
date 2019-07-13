//
//  SearchMastodonTableViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/19.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Feeder
import Nuke
import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

final class SearchMastodonTableViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    private let decisionTrigger = PublishSubject<String>()
    private let searchBar: UISearchBar
    private let viewModel: SearchMastodonTableViewModelType

    let decision: Observable<String>

    // MARK: - Initializer

    init() {
        decision = decisionTrigger.asObserver()
        searchBar = UISearchBar()
        searchBar.placeholder = "例: mstdn.jp"
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

        tableView.register(R.nib.mastodonDomainTableViewCell)

        tableView.rx.modelSelected(Instance.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (instance) in
                let alert = UIAlertController(title: "\(instance.name)\nこのインスタンスに設定します", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
                    self.navigationController?.popViewController(animated: true)
                    self.decisionTrigger.onNext(instance.name)
                    self.decisionTrigger.onCompleted()
                })
                alert.preferredAction = alert.actions.last
                self.present(alert, animated: true, completion: nil)
                Feeder.Impact(.light).impactOccurred()
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.tableView.deselectRow(at: $0, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.isLoading
            .observeOn(MainScheduler.instance)
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)

        viewModel.outputs.mastodonInstances
            .observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: R.reuseIdentifier.mastodonDomainTableViewCell.identifier)) {
                guard let cell = $2 as? MastodonDomainTableViewCell else { return }
                cell.instance = $1
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
