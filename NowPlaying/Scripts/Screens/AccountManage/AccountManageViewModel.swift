//
//  AccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import Feeder
import RealmSwift
import RxCocoa
import RxSwift
import SafariServices
import SVProgressHUD
import Swifter
import UIKit

// MARK: - AccountManageViewModelInput

protocol AccountManageViewModelInput {

    var twitterLoginTrigger: PublishRelay<UIViewController> { get }
    var removeUserDataTrigger: PublishRelay<User> { get }
    var newDefaultAccountTrigger: PublishRelay<Void> { get }
    var tokenRevokeTrigger: PublishRelay<SecretCredential> { get }
}

// MARK: - AccountManageViewModelOutput

protocol AccountManageViewModelOutput {

    var title: Observable<String> { get }
    var loginResult: Observable<LoginResult> { get }
    var removeResult: Observable<Void> { get }
    var newDefaultAccount: Observable<UIAlertController> { get }
    var tokenRevokeResult: Observable<User> { get }
}

// MARK: - AccountManageViewModelType

protocol AccountManageViewModelType {

    var inputs: AccountManageViewModelInput { get }
    var outputs: AccountManageViewModelOutput { get }

    init(service: Service)
}

enum LoginResult {
    case initial(User)
    case success(User)
    case failure(Error)
    case duplicate
}

final class AccountManageViewModelImpl: AccountManageViewModelType {

    /* Input */
    let twitterLoginTrigger: PublishRelay<UIViewController> = .init()
    let removeUserDataTrigger: PublishRelay<User> = .init()
    let newDefaultAccountTrigger: PublishRelay<Void> = .init()
    let tokenRevokeTrigger: PublishRelay<SecretCredential> = .init()
    /* Output */
    let title: Observable<String>
    let loginResult: Observable<LoginResult>
    let removeResult: Observable<Void>
    let newDefaultAccount: Observable<UIAlertController>
    let tokenRevokeResult: Observable<User>

    var inputs: AccountManageViewModelInput { return self }
    var outputs: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let _loginResult = PublishRelay<LoginResult>()
    private let _removeResult = PublishSubject<Void>()
    private let _newDefaultAccount = PublishRelay<UIAlertController>()
    private let _tokenRevokeResult = PublishSubject<User>()
    private let mastodonTokenRevokeAction: Action<SecretCredential, Void> = Action {
        return Session.shared.rx.response(MastodonTokenRevokeRequest(secret: $0))
    }
    private let service: Service

    private lazy var twitter = TwitterSessionControl()
    private lazy var mastodon = MastodonSessionControl()

    init(service: Service) {
        self.service = service
        switch service {
        case .twitter:
            title = Observable.just("Twitterアカウント")
        case .mastodon:
            title = Observable.just("Mastodonアカウント")
        }

        loginResult = _loginResult.asObservable()
        removeResult = _removeResult.asObservable()
        newDefaultAccount = _newDefaultAccount.asObservable()
        tokenRevokeResult = _tokenRevokeResult.asObservable()

        twitterLoginTrigger
            .subscribe(onNext: { [unowned self] in
                self.startTwitterLogin($0)
            })
            .disposed(by: disposeBag)

        removeUserDataTrigger
            .subscribe(onNext: { [unowned self] (user) in
                self.removeUserData(user)
            })
            .disposed(by: disposeBag)

        newDefaultAccountTrigger
            .subscribe(onNext: { [unowned self] in
                self.applyNewDefaultAccount()
            })
            .disposed(by: disposeBag)

        tokenRevokeTrigger
            .subscribe(onNext: { [unowned self] (secret) in
                self.tokenRevoke(secret: secret)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private method

extension AccountManageViewModelImpl {

    private func removeUserData(_ user: User) {
        do {
            let realm = try Realm(configuration: realmConfiguration)
            try realm.write {
                realm.delete(user.secretCredentials.first!)
                realm.delete(user)
            }
            _removeResult.onCompleted()
        } catch {
            _removeResult.onError(error)
        }
    }

    private func applyNewDefaultAccount() {
        let realm = try! Realm(configuration: realmConfiguration)
        guard let user = realm.objects(User.self).filter("serviceType = %@", service.rawValue)
            .sorted(byKeyPath: "id", ascending: true).first, !user.isDefault else {
                return
        }
        try! realm.write {
            user.isDefault = true
        }
        let alert = UIAlertController(title: "デフォルトアカウント変更", message: "\(user.name)に設定されました", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        Feeder.Selection().selectionChanged()
        _newDefaultAccount.accept(alert)
    }

    private func tokenRevoke(secret: SecretCredential) {
        mastodonTokenRevokeAction.elements
            .subscribe(onNext: { [weak self] in
                self?._tokenRevokeResult.onNext(secret.user!)
                self?._tokenRevokeResult.onCompleted()
            }, onError: { [weak self] in
                self?._tokenRevokeResult.onError($0)
            })
            .disposed(by: self.disposeBag)

        mastodonTokenRevokeAction.inputs.onNext(secret)
    }

    private func startTwitterLogin(_ viewController: UIViewController) {
        let twitterAuthURL = URL(string: "twitterauth://authorize")!
        if UIApplication.shared.canOpenURL(twitterAuthURL) {
            twitter.tryAuthorizeSSO()
                .subscribe(onNext: { [weak self] in
                    guard let wself = self else { return }
                    TwitterSessionControl.handleSuccessLogin($0)
                        .bind(to: wself.twitterLoginHandle)
                }, onError: { [weak self] in
                    print($0)
                    self?._loginResult.accept(.failure($0))
                })
                .disposed(by: disposeBag)
            return
        }
        twitter.tryAuthorizeBrowser(presenting: viewController)
            .subscribe(onNext: { [weak self] in
                guard let wself = self else { return }
                TwitterSessionControl.handleSuccessLogin($0)
                    .bind(to: wself.twitterLoginHandle)
            }, onError: { [weak self] (error) in
                print(error)
                self?._loginResult.accept(.failure(error))
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
            let viewController = SearchMastodonViewController()
            _ = viewController.decision
                .bind(to: observer.asObserver())

//            inputs.viewController.navigationController?.pushViewController(viewController, animated: true)
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

// MARK: - AccountManageViewModelInput

extension AccountManageViewModelImpl: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension AccountManageViewModelImpl: AccountManageViewModelOutput {}
