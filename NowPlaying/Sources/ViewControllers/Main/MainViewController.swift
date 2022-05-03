//
//  MainViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/26.
//

import UIKit

final class MainViewController: UIViewController {
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let router = PlayerRouter()
        let viewModel = PlayViewModel(router: router)
        let viewController = PlayViewController(dependency: viewModel)
        router.inject(viewController)
        addContainerViewController(viewController, to: view)
    }
}
