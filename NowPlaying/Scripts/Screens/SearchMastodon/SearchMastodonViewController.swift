//
//  SearchMastodonViewController.swift
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

final class SearchMastodonViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private let disposeBag = DisposeBag()
    private let decisionTrigger = PublishSubject<String>()
    private let searchBar: UISearchBar
    private let viewModel: SearchMastodonViewModelType

    let decision: Observable<String>

    // MARK: - Initializer

    init() {
        decision = decisionTrigger.asObserver()
        searchBar = UISearchBar()
        searchBar.placeholder = "例: mstdn.jp"
        let inputs = SearchMastodonViewModelInput(searchBarText: searchBar.rx.text.asObservable())
        viewModel = SearchMastodonViewModel(inputs: inputs)
        super.init(nibName: R.nib.searchMastodonViewController.name, bundle: R.nib.searchMastodonViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(R.nib.mastodonDomainTableViewCell)
        tableView.rx.setDelegate(self).disposed(by: disposeBag)

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

// MARK: - UITableViewDelegate

extension SearchMastodonViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
}
