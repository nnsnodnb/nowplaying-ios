//
//  PostViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class PostViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private(set) var viewModel: PostViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewModel.outputs.title.bind(to: rx.title)

        setupNavigationBar()
    }

    // MARK: - Private method

    private func setupNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain, target: nil, action: nil)
        let rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: nil, action: nil)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem

        leftBarButtonItem.rx.tap.bind(to: viewModel.inputs.dismissTrigger).disposed(by: disposeBag)
        rightBarButtonItem.rx.tap.bind(to: viewModel.inputs.postTrigger).disposed(by: disposeBag)
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
