//
//  AppDelegateViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import RxCocoa
import RxSwift
import UIKit

// MARK: - AppDelegateViewModelInput

protocol AppDelegateViewModelInput {

    var checkAppVersionTrigger: PublishSubject<Void> { get }
}

// MARK: - AppDelegateViewModelOutput

protocol AppDelegateViewModelOutput {

    var presentAlert: Observable<UIAlertController> { get }
}

// MARK: - AppDelegateViewModelType

protocol AppDelegateViewModelType {

    var inputs: AppDelegateViewModelInput { get }
    var outputs: AppDelegateViewModelOutput { get }

    init()
}

final class AppDelegateViewModel: AppDelegateViewModelType {

    let presentAlert: Observable<UIAlertController>
    let checkAppVersionTrigger = PublishSubject<Void>()

    var inputs: AppDelegateViewModelInput { return self }
    var outputs: AppDelegateViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let checkAppVersionAction: Action<Void, AppInfoResponse>

    init() {
        let alertTrigger = PublishSubject<UIAlertController>()
        presentAlert = alertTrigger.asObservable()
            .compactMap { $0 }
            .subscribeOn(MainScheduler.instance)

        checkAppVersionAction = Action {
            return Session.shared.rx.response(AppInfoRequest())
        }

        setInitialData()

        checkAppVersionTrigger
            .bind(to: checkAppVersionAction.inputs)
            .disposed(by: disposeBag)

        checkAppVersionAction.elements
            .subscribe(onNext: { [weak self] (response) in
                guard let alert = self?.handleAppVersionResponse(response) else { return }
                alertTrigger.onNext(alert)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private method

extension AppDelegateViewModel {

    private func setInitialData() {
        if UserDefaults.string(forKey: .tweetFormat) == nil {
            UserDefaults.set(.defaultPostFormat, forKey: .tweetFormat)
        }
        if UserDefaults.string(forKey: .tweetWithImageType) == nil {
            UserDefaults.set(WithImageType.onlyArtwork.rawValue, forKey: .tweetWithImageType)
        }
        if UserDefaults.string(forKey: .tootFormat) == nil {
            UserDefaults.set(.defaultPostFormat, forKey: .tootFormat)
        }
        if UserDefaults.string(forKey: .tootWithImageType) == nil {
            UserDefaults.set(WithImageType.onlyArtwork.rawValue, forKey: .tootWithImageType)
        }
    }

    private func handleAppVersionResponse(_ response: AppInfoResponse) -> UIAlertController? {
        let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        if current.compare(response.appVersion.require, options: .numeric) == .orderedAscending {
            // 必須アップデート
            let alert = UIAlertController(title: "アップデートが必要です", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "AppStoreを開く", style: .default) { (_) in
                UIApplication.shared.open(URL(string: websiteURL)!, options: [:], completionHandler: nil)
            })
            alert.preferredAction = alert.actions.first
            return alert
        } else if current.compare(response.appVersion.latest, options: .numeric) == .orderedAscending {
            // アップデートあり
            let alert = UIAlertController(title: "アップデートがあります", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "あとで", style: .cancel, handler: nil))
            let action = UIAlertAction(title: "AppStoreを開く", style: .default) { (_) in
                let url = URL(string: websiteURL)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alert.addAction(action)
            alert.preferredAction = action
            return alert
        } else { return nil }
    }
}

// MARK: - AppDelegateViewModelInput

extension AppDelegateViewModel: AppDelegateViewModelInput {}

// MARK: - AppDelegateViewModelOutput

extension AppDelegateViewModel: AppDelegateViewModelOutput {}
