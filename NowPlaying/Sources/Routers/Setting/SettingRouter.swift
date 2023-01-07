//
//  SettingRouter.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import RxCocoa
import RxSwift
import UIKit

protocol SettingRoutable: Routable {
    var dismiss: PublishRelay<Void> { get }
    var twitter: PublishRelay<Void> { get }
    var mastodon: PublishRelay<Void> { get }
    var safari: PublishRelay<URL> { get }
    var appStore: PublishRelay<Void> { get }
}

final class SettingRouter: NSObject, SettingRoutable {
    // MARK: - Properties
    private(set) weak var viewController: UIViewController?

    let dismiss: PublishRelay<Void> = .init()
    let twitter: PublishRelay<Void> = .init()
    let mastodon: PublishRelay<Void> = .init()
    let safari: PublishRelay<URL> = .init()
    let appStore: PublishRelay<Void> = .init()

    private let environment: EnvironmentProtocol
    private let disposeBag = DisposeBag()

    // MARK: - Initialize
    init(environment: EnvironmentProtocol) {
        self.environment = environment
        super.init()
        // 閉じる
        dismiss.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                strongSelf.viewController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        // Twitter設定
        twitter.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                strongSelf.showSettingProviderViewController(with: .twitter)
            })
            .disposed(by: disposeBag)
        // Mastodon設定
        mastodon.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                strongSelf.showSettingProviderViewController(with: .mastodon)
            })
            .disposed(by: disposeBag)
        // SFSafariViewController
        safari.asSignal()
            .emit(with: self, onNext: { strongSelf, url in
                strongSelf.viewController?.presentSafariViewController(url: url)
            })
            .disposed(by: disposeBag)
        // AppStore
        appStore.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                let url = URL(string: "\(URL.appStore.absoluteString)&action=write-review")!
                strongSelf.viewController?.presentSafariViewController(url: url)
            })
            .disposed(by: disposeBag)
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}

// MARK: - Private method
private extension SettingRouter {
    func showSettingProviderViewController(with socialType: SocialType) {
        let router = SettingProviderRouter(environment: environment, socialType: socialType)
        let viewModel = SettingProviderViewModel(router: router, socialType: socialType)
        let viewController = SettingProviderViewController(dependency: viewModel, environment: environment)
        router.inject(viewController)
        self.viewController?.navigationController?.presentationController?.delegate = self
        self.viewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SettingRouter: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        guard let viewController,
              let children = viewController.navigationController?.children else { return true }
        return children == [viewController]
    }
}
