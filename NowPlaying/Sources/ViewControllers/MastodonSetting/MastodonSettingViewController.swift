//
//  MastodonSettingViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import UIKit

final class MastodonSettingViewController: UIViewController {
    // MARK: - Dependency
    typealias Dependency = MastodonSettingViewModelType

    // MARK: - Properties
    private let viewModel: MastodonSettingViewModelType
    private let environment: EnvironmentProtocol

    @IBOutlet private var tableView: UITableView!

    // MARK: - Initialize
    init(dependency: Dependency, environment: EnvironmentProtocol) {
        self.viewModel = dependency
        self.environment = environment
        super.init(nibName: Self.className, bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Mastodon設定"
        bind(to: viewModel)
    }
}

// MARK: - Private method
private extension MastodonSettingViewController {
    func bind(to viewModel: MastodonSettingViewModelType) {
    }
}

// MARK: - ViewControllerInjectable
extension MastodonSettingViewController: ViewControllerInjectable {}
