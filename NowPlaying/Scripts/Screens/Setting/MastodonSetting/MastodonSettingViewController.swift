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

    private var viewModel: MastodonSettingViewModelType!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mastodon設定"
        let backBarButtonItem = UIBarButtonItem(title: "戻る", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem

        viewModel = MastodonSettingViewModel(inputs: MastodonSettingViewModelInput(viewController: self))

        form = viewModel.form

        viewModel.outputs.error
            .subscribe(onNext: { [weak self] (_) in
                self?.showMastodonError()
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
