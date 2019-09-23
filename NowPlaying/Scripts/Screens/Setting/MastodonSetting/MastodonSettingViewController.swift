//
//  MastodonSettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/07/22.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Eureka
import FirebaseAnalytics
import RxSwift
import SafariServices
import UIKit

final class MastodonSettingViewController: FormViewController {

    private let disposeBag = DisposeBag()
    private let viewModel: MastodonSettingViewModelType

    // MARK: - Initializer

    init(viewModel: MastodonSettingViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: R.nib.mastodonSettingViewController.name, bundle: R.nib.mastodonSettingViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mastodon設定"
        let backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem

        form = viewModel.outputs.form

        viewModel.outputs.error
            .subscribe(onNext: { [weak self] (_) in
                self?.showMastodonError()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.transition
            .subscribe(onNext: { [unowned self] (transition) in
                switch transition {
                case .manage:
                    let viewController = AccountManageViewController(viewModel: AccountManageViewModelImpl(service: .mastodon),
                                                                     service: .mastodon, screenType: .settings)
                    self.navigationController?.pushViewController(viewController, animated: true)
                case .alert(let configuration):
                    self.present(configuration.make(), animated: true, completion: nil)
                }
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("Mastodon設定画面", screenClass: "MastodonSettingViewController")
        Analytics.logEvent("screen_open", parameters: nil)
    }

    // MARK: - Private method

    private func showMastodonError() {
        let alert = UIAlertController(title: "エラー", message: "Mastodonのドメインを確認してください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
