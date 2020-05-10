//
//  PreviewViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/09.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class PreviewViewController: UIViewController {

    @IBOutlet private weak var previewImageView: UIImageView! {
        didSet {
            previewImageView.hero.isEnabled = true
            previewImageView.hero.id = "attachmentPreview"
        }
    }

    private(set) var viewModel: PreviewViewModelType!

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = viewModel.outputs.previewImage.bind(to: previewImageView.rx.image)

        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        navigationItem.rightBarButtonItem = rightBarButtonItem
        rightBarButtonItem.rx.tap.bind(to: viewModel.inputs.closeButton).disposed(by: disposeBag)
    }
}

// MARK: - PreviewViewer

extension PreviewViewController: PreviewViewer {}

extension PreviewViewController {

    struct Dependency {
        let viewModel: PreviewViewModelType
    }

    class func makeInstance(image: UIImage) -> PreviewViewController {
        let viewController = PreviewViewController()
        let router = PreviewRouter(view: viewController)
        let viewModel = PreviewViewModel(router: router, image: image)
        viewController.inject(dependency: .init(viewModel: viewModel))
        viewController.hero.isEnabled = true
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
