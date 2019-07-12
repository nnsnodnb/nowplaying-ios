//
//  AccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import RealmSwift
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD
import SwifteriOS
import UIKit

struct AccountManageViewModelInput {

    let service: Service
    let addAccountBarButtonItem: UIBarButtonItem
    let editAccountsBarButtonItem: UIBarButtonItem
    let viewController: UIViewController
}

// MARK: - AccountManageViewModelOutput

protocol AccountManageViewModelOutput {

    var title: Observable<String> { get }
    var users: Observable<Results<User>> { get }
    var loginResult: Observable<LoginResult> { get }
}

// MARK: - AccountManageViewModelType

protocol AccountManageViewModelType {

    var outputs: AccountManageViewModelOutput { get }

    init(inputs: AccountManageViewModelInput)
    func tokenRevoke(secret: SecretCredential) -> Observable<Void>
    func removeUserData(_ user: User) -> Observable<Void>
    func applyNewDefaultAccount() -> Observable<UIAlertController>
}

enum LoginResult {
    case initial(User)
    case success(User)
    case failure(Error)
    case duplicate
}

final class AccountManageViewModel: AccountManageViewModelType {

    let title: Observable<String>
    let users: Observable<Results<User>>
    let loginResult: Observable<LoginResult>

    var outputs: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _loginResult = PublishRelay<LoginResult>()
    private let mastodonTokenRevokeAction: Action<SecretCredential, Void> = Action {
        return Session.shared.rx.response(MastodonTokenRevokeRequest(secret: $0))
    }
    private let service: Service

    private lazy var twitter = TwitterSessionControl()
    private lazy var mastodon = MastodonSessionControl()

    init(inputs: AccountManageViewModelInput) {
        service = inputs.service
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

    func tokenRevoke(secret: SecretCredential) -> Observable<Void> {
        return .create { [unowned self] (observer) -> Disposable in
            self.mastodonTokenRevokeAction.elements
                .subscribe(onNext: {
                    observer.onNext(())
                    observer.onCompleted()
                }, onError: {
                    observer.onError($0)
                })
                .disposed(by: self.disposeBag)

            self.mastodonTokenRevokeAction.inputs.onNext(secret)
            return Disposables.create()
        }
    }

    func removeUserData(_ user: User) -> Observable<Void> {
        return .create { (observer) -> Disposable in
            let realm = try! Realm(configuration: realmConfiguration)
            try! realm.write {
                realm.delete(user.secretCredentials.first!)
                realm.delete(user)
            }
            observer.onCompleted()

            return Disposables.create()
        }
    }

    func applyNewDefaultAccount() -> Observable<UIAlertController> {
        return .create { [service] (observer) -> Disposable in
            let realm = try! Realm(configuration: realmConfiguration)
            guard let user = realm.objects(User.self).filter("serviceType = %@", service.rawValue)
                .sorted(byKeyPath: "id", ascending: true).first else {
                    observer.onCompleted()
                    return Disposables.create()
            }
            try! realm.write {
                user.isDefault = true
            }
            let alert = UIAlertController(title: "デフォルトアカウント変更", message: "\(user.name)に設定されました", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            observer.onNext(alert)
            observer.onCompleted()

            return Disposables.create()
        }
    }
}

// MARK: - Private method

extension AccountManageViewModel {

    private func subscribeBarButtonItems(inputs: AccountManageViewModelInput) {
        inputs.addAccountBarButtonItem.rx.tap
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
                            self._loginResult.accept(.failure(error))
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)

        inputs.editAccountsBarButtonItem.rx.tap
            .subscribe(onNext: {
                let isEditing = !inputs.viewController.isEditing
                inputs.viewController.setEditing(isEditing, animated: true)
                let newTitle = isEditing ? "完了" : "編集"
                inputs.editAccountsBarButtonItem.title = newTitle
            })
            .disposed(by: disposeBag)
    }

    private func startTwitterLogin(inputs: AccountManageViewModelInput) {
        let twitterAuthURL = URL(string: "twitterauth://authorize")!
        if UIApplication.shared.canOpenURL(twitterAuthURL) {
            twitter.tryAuthorizeSSO()
                .subscribe(onNext: { [weak self] in
                    guard let wself = self else { return }
                    TwitterSessionControl.handleSuccessLogin($0)
                        .bind(to: wself.twitterLoginHandle)
                }, onError: { [unowned self] in
                    print($0)
                    self._loginResult.accept(.failure($0))
                })
                .disposed(by: disposeBag)
            return
        }
        twitter.tryAuthorizeBrowser(presenting: inputs.viewController)
            .subscribe(onNext: { [weak self] in
                guard let wself = self else { return }
                TwitterSessionControl.handleSuccessLogin($0)
                    .bind(to: wself.twitterLoginHandle)
            }, onError: { [unowned self] (error) in
                print(error)
                self._loginResult.accept(.failure(error))
            })
            .disposed(by: disposeBag)
    }

    private func twitterLoginHandle(_ callback: Observable<LoginCallback>) {
        callback
            .subscribe(onNext: { [weak self] (callback) in
                let user = User(serviceID: callback.userID, name: callback.name,
                                screenName: callback.screenName, iconURL: callback.photoURL, serviceType: .twitter)
                let credential = SecretCredential(consumerKey: .twitterConsumerKey, consumerSecret: .twitterConsumerSecret,
                                                  authToken: callback.accessToken, authTokenSecret: callback.accessTokenSecret, user: user)
                let result: LoginResult
                do {
                    let realm = try Realm(configuration: realmConfiguration)
                    // 重複チェック
                    if try user.isExists() {
                        result = .duplicate
                    } else {
                        try realm.write {
                            realm.add(user, update: .error)
                            realm.add(credential, update: .error)
                        }
                        let isEmpty = realm.objects(User.self)
                            .filter("serviceID != %@ AND serviceType = %@", user.serviceID, user.serviceType)
                            .isEmpty
                        result = isEmpty ? .initial(user) : .success(user)
                    }
                } catch {
                    print(error)
                    result = .failure(error)
                }
                SVProgressHUD.dismiss { self?._loginResult.accept(result) }
            }, onError: { [weak self] (error) in
                SVProgressHUD.dismiss { self?._loginResult.accept(.failure(error)) }
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
        _ = mastodon.authorize(hostname: hostname)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (secret) in
                let user = User(serviceID: secret.userID, name: secret.name, screenName: secret.screenName,
                                iconURL: secret.photoURL!, serviceType: .mastodon)
                let secretCredential = SecretCredential(consumerKey: secret.clientID, consumerSecret: secret.clientSecret,
                                                        authToken: secret.accessToken, domainName: secret.domain, user: user)
                do {
                    let realm = try Realm(configuration: realmConfiguration)
                    if try user.isExists() {
                        self?._loginResult.accept(.duplicate)
                        return
                    }
                    try realm.write {
                        realm.add(user, update: .error)
                        realm.add(secretCredential, update: .error)
                    }
                    let isEmpty = realm.objects(User.self)
                        .filter("serviceID != %@ AND serviceType = %@", user.serviceID, user.serviceType)
                        .isEmpty
                    let result: LoginResult = isEmpty ? .initial(user) : .success(user)
                    self?._loginResult.accept(result)
                } catch {
                    print(error)
                    self?._loginResult.accept(.failure(error))
                }
            }, onError: { [weak self] in
                print($0)
                self?._loginResult.accept(.failure($0))
            })
    }
}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModel: AccountManageViewModelOutput {}
