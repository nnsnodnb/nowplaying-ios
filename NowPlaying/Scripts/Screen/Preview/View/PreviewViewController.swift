//
//  PreviewViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/09.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class PreviewViewController: UIViewController {

    private(set) var viewModel: PreviewViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - PreviewViewer

extension PreviewViewController: PreviewViewer {}

extension PreviewViewController {

    struct Dependency {
        let viewModel: PreviewViewModelType
    }

    class func makeInstance() -> PreviewViewController {
        let viewController = PreviewViewController()
        let router = PreviewRouter(view: viewController)
        let viewModel = PreviewViewModel(router: router)
        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
