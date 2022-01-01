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
        let viewModel = PlayViewModel()
        let viewController = PlayViewController(dependency: viewModel)
        addContainerViewController(viewController, to: view)
    }
}
