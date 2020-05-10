//
//  PostViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Hero
import MediaPlayer
import RxCocoa
import RxSwift
import UIKit

final class PostViewController: UIViewController {

    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.textContainerInset = .init(top: 0, left: 14 * 2 + 60, bottom: 0, right: 14)
            textView.becomeFirstResponder()
            textView.rx.text.orEmpty.bind(to: viewModel.inputs.postText).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var iconImageButton: UIButton! {
        didSet {
            iconImageButton.imageView?.contentMode = .scaleAspectFit
            iconImageButton.contentVerticalAlignment = .fill
            iconImageButton.contentHorizontalAlignment = .fill
            iconImageButton.rx.tap.bind(to: viewModel.inputs.changeAccount).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var attachmentImageButton: UIButton! {
        didSet {
            attachmentImageButton.hero.isEnabled = true
            attachmentImageButton.hero.id = "attachmentPreview"
            attachmentImageButton.imageView?.contentMode = .scaleAspectFit
            attachmentImageButton.contentVerticalAlignment = .fill
            attachmentImageButton.contentHorizontalAlignment = .fill
            attachmentImageButton.rx.tap.bind(to: viewModel.inputs.selectAttachment).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var addImageButton: UIButton! {
        didSet {
            addImageButton.rx.tap.bind(to: viewModel.inputs.addAttachment).disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()

    private(set) var viewModel: PostViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        hero.isEnabled = true

        _ = viewModel.outputs.title.bind(to: rx.title)
        _ = viewModel.outputs.initialPostText.bind(to: textView.rx.text)

        viewModel.outputs.account.map { $0.iconURL }.bind(to: iconImageButton.rx.url).disposed(by: disposeBag)
        viewModel.outputs.attachment.bind(to: attachmentImageButton.rx.image(for: .normal)).disposed(by: disposeBag)
        viewModel.outputs.attachment.map { $0 == nil }.bind(to: attachmentImageButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.attachment.map { $0 != nil }.bind(to: addImageButton.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.keyboardHeight.bind(to: textViewBottomConstraint.rx.constant).disposed(by: disposeBag)

        setupNavigationBar()

        if #available(iOS 13.0, *) {
            navigationController?.presentationController?.delegate = self

            viewModel.outputs.didChangePostText
                .observeOn(MainScheduler.instance)
                .bind(to: rx.isModalInPresentation)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private method

    private func setupNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain, target: nil, action: nil)
        let rightBarButtonItem = UIBarButtonItem(title: title, style: .done, target: nil, action: nil)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtonItem

        leftBarButtonItem.rx.tap.bind(to: viewModel.inputs.dismissTrigger).disposed(by: disposeBag)
        rightBarButtonItem.rx.tap.bind(to: viewModel.inputs.postTrigger).disposed(by: disposeBag)

        viewModel.outputs.enablePostButton.bind(to: rightBarButtonItem.rx.isEnabled).disposed(by: disposeBag)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension PostViewController: UIAdaptivePresentationControllerDelegate {

    @available(iOS 13.0, *)
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        viewModel.inputs.didAttemptToDismiss.accept(())
    }
}

// MARK: - PostViewer

extension PostViewController: PostViewer {}

extension PostViewController {

    struct Dependency {
        let viewModel: PostViewModelType
    }

    class func makeInstance(service: Service, item: MPMediaItem, screenshot: UIImage) -> PostViewController {
        let viewController = PostViewController()
        let router = PostRouter(view: viewController)
        let viewModel: PostViewModelType
        switch service {
        case .twitter:
            viewModel = TweetPostViewModel(router: router, item: item, screenshot: screenshot)
        case .mastodon:
            viewModel = TootPostViewModel(router: router, item: item, screenshot: screenshot)
        }
        viewController.inject(dependency: .init(viewModel: viewModel))
        return viewController
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
