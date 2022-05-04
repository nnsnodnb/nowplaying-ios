//
//  TwitterSettingViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

final class TwitterSettingViewController: UIViewController {
    // MARK: - Dependency
    typealias Dependency = TwitterSettingViewModelType

    // MARK: - Properties
    private let viewModel: TwitterSettingViewModelType

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = .init()
        }
    }

    // MARK: - Initialize
    init(dependency: Dependency) {
        self.viewModel = dependency
        super.init(nibName: Self.className, bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
    }
}

// MARK: - Private method
private extension TwitterSettingViewController {
    func bind(to viewModel: TwitterSettingViewModelType) {
    }
}

// MARK: - ViewControllerInjectable
extension TwitterSettingViewController: ViewControllerInjectable {}
