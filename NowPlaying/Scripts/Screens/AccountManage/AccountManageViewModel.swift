//
//  AccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RealmSwift
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD
import SwifteriOS
import UIKit

struct AccountManageViewModelInput {

    let service: Service
    let addAccountBarButtonItem: Observable<Void>
    let editAccountsBarButtonItem: Observable<Void>
    let viewController: UIViewController
}

// MARK: - AccountManageViewModelOutput

protocol AccountManageViewModelOutput {

    var title: Observable<String> { get }
    var users: Observable<Results<User>> { get }
    var loginResult: Observable<Bool> { get }
}

// MARK: - AccountManageViewModelType

protocol AccountManageViewModelType {

    var outputs: AccountManageViewModelOutput { get }

    init(inputs: AccountManageViewModelInput)
}

final class AccountManageViewModel: AccountManageViewModelType {

    let title: Observable<String>
    let users: Observable<Results<User>>
    let loginResult: Observable<Bool>

    var outputs: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _loginResult = PublishRelay<Bool>()

    private lazy var twitter = TwitterSessionControl()
    private lazy var mastodon = MastodonSessionControl()

    init(inputs: AccountManageViewModelInput) {
        switch inputs.service {
        case .twitter:
            title = Observable.just("Twitterアカウント")
        case .mastodon:
            title = Observable.just("Mastodonアカウント")
        }
        let realm = try! Realm(configuration: realmConfiguration)
        users = realm.objects(User.self)
            .filter("serviceType = %@", inputs.service.rawValue)
            .sorted(byKeyPath: "id", ascending: true)
            .response()
            .asObservable()

        loginResult = _loginResult.asObservable()

        subscribeBarButtonItems(inputs: inputs)
    }

    private func subscribeBarButtonItems(inputs: AccountManageViewModelInput) {
        inputs.addAccountBarButtonItem
            .subscribe(onNext: { [unowned self] in
                switch inputs.service {
                case .twitter:
                    SVProgressHUD.show()
                    self.startTwitterLogin(inputs: inputs)
                case .mastodon:
                    self.startMastodonLogin(inputs: inputs)
                        .subscribe(onNext: { (hostname) in
                            self.startAuthorizeMastodon(hostname: hostname)
                        }, onError: { (error) in
                            print(error)
                            self._loginResult.accept(false)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)

        inputs.editAccountsBarButtonItem
            .subscribe(onNext: {

            })
            .disposed(by: disposeBag)
    }

    private func startTwitterLogin(inputs: AccountManageViewModelInput) {
        twitter.authorize(presenting: inputs.viewController)
            .subscribe(onNext: { [weak self] (callback) in
                let user = User(serviceID: callback.userID, name: callback.name,
                                screenName: callback.screenName, iconURL: callback.photoURL, serviceType: .twitter)
                let credential = SecretCredential(consumerKey: .twitterConsumerKey, consumerSecret: .twitterConsumerSecret,
                                                   authToken: callback.accessToken, authTokenSecret: callback.accessTokenSecret, user: user)
                let result: Bool
                do {
                    let realm = try Realm(configuration: realmConfiguration)
                    try realm.write {
                        realm.add(user, update: .error)
                        realm.add(credential, update: .error)
                    }
                    result = true
                } catch {
                    print(error)
                    result = false
                }
                SVProgressHUD.dismiss { self?._loginResult.accept(result) }
            }, onError: { [weak self] (error) in
                print(error)
                SVProgressHUD.dismiss { self?._loginResult.accept(false) }
            })
            .disposed(by: disposeBag)
    }

    private func startMastodonLogin(inputs: AccountManageViewModelInput) -> Observable<String> {
        // ドメイン検索 → アプリ登録 → SFSafariViewControllerでのOAuth認証 → トークンを取得
        return .create { [unowned self] (observer) -> Disposable in
            let viewController = SearchMastodonTableViewController()
            viewController.decision
                .bind(to: observer.asObserver())
                .disposed(by: self.disposeBag)

            inputs.viewController.navigationController?.pushViewController(viewController, animated: true)
            return Disposables.create()
        }
    }

    private func startAuthorizeMastodon(hostname: String) {
        mastodon.authorize(hostname: hostname)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (secret) in
                do {
                    let user = User(serviceID: secret.userID, name: secret.name, screenName: secret.screenName,
                                    iconURL: secret.photoURL!, serviceType: .mastodon)
                    let secretCredential = SecretCredential(consumerKey: secret.clientID, consumerSecret: secret.clientSecret,
                                                            authToken: secret.accessToken, domainName: secret.domain, user: user)
                    let realm = try Realm(configuration: realmConfiguration)
                    try realm.write {
                        realm.add(user, update: .error)
                        realm.add(secretCredential, update: .error)
                    }
                    self?._loginResult.accept(true)
                } catch {
                    print(error)
                    self?._loginResult.accept(false)
                }
            }, onError: { [weak self] in
                print($0)
                self?._loginResult.accept(false)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
