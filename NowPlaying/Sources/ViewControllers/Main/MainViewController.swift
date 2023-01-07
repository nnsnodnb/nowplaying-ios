//
//  MainViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/26.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: - Dependency
    typealias Dependency = Void

    // MARK: - Properties
    private let environment: EnvironmentProtocol

    // MARK: - Initialize
    init(environment: EnvironmentProtocol) {
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
        let router = PlayerRouter(environment: environment)
        let viewModel = PlayViewModel(router: router)
        let viewController = PlayViewController(dependency: viewModel, environment: environment)
        router.inject(viewController)
        addContainerViewController(viewController, to: view)
    }
}

// MARK: - ViewControllerInjectable
extension MainViewController: ViewControllerInjectable {}
