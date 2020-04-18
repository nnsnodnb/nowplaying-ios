//
//  SettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import RxCocoa
import RxSwift
import UIKit

final class SettingViewController: FormViewController {

    private let disposeBag = DisposeBag()

    private(set) var viewModel: SettingViewModelType!

    // MARK: - Class method

    class func makeInstance() -> SettingViewController {
        let viewController = SettingViewController()
        let router = SettingRouterImpl(view: viewController)
        let viewModel = SettingViewModel(router: router)
        viewController.inject(dependency: .init(viewModel: viewModel))

        return viewController
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "設定"
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        rightBarButtonItem.rx.tap.bind(to: viewModel.input.closeTrigger).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
}

extension SettingViewController: SettingViewer {}

extension SettingViewController {

    struct Dependency {
        let viewModel: SettingViewModelType
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
