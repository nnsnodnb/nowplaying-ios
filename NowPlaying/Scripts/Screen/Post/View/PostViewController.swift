//
//  PostViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

final class PostViewController: UIViewController {

    private(set) var viewModel: PostViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - PostViewer

extension PostViewController: PostViewer {}

extension PostViewController {

    struct Dependency {
        let viewModel: PostViewModelType
    }

    class func makeInstance(service: Service) -> PostViewController {
        let viewController = PostViewController()
        let router = PostRouter(view: viewController)
        let viewModel: PostViewModelType = service == .twitter ? TweetPostViewModel(router: router) : TootPostViewModel(router: router)
        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
