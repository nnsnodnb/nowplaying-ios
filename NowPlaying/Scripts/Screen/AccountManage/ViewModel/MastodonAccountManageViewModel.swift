//
//  MastodonAccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import Foundation
import MastodonKit
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift
import SafariServices
import SVProgressHUD

final class MastodonAccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let deleteTrigger: PublishRelay<User> = .init()
    let cellSelected: PublishRelay<User> = .init()
    let dataSource: Observable<(AnyRealmCollection<User>, RealmChangeset?)>
    let loginSuccess: Observable<String>
    let loginError: Observable<String>
    let service: Service = .mastodon

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let hostname: PublishRelay<String> = .init()
    private let loginSuccessTrigger: PublishRelay<String> = .init()
    private let loginErrorTrigger: PublishRelay<Error> = .init()

    private lazy var registerAppAction: Action<String, ClientApplication> = .init {
        return Client.create(baseURL: $0).rx.response(Clients.registerNowPlaying())
    }
    private lazy var authorizeAction: Action<(String, ClientApplication), String> = .init {
        return SFAuthenticationSession.rx.authorize(hostname: $0.0, application: $0.1)
    }
    private lazy var loginAppAction: Action<(String, Login.OAuthParameter), LoginSettings> = .init {
        return Client.create(baseURL: $0.0).rx.response(Login.oauth($0.1))
    }
    private lazy var verifyTokenAction: Action<(String, String), Account> = .init {
        return Client.create(baseURL: $0.0, accessToken: $0.1).rx.response(Accounts.currentUser())
    }

    init(router: AccountManageRoutable) {
        let realm = try! Realm(configuration: realmConfiguration)
        let results = realm.objects(User.self).filter("serviceType = %@", service.rawValue).sorted(byKeyPath: "id", ascending: true)
        dataSource = Observable.changeset(from: results)

        loginSuccess = loginSuccessTrigger.map { "@\($0)" }.observeOn(MainScheduler.instance).asObservable()
        loginError = loginErrorTrigger.map { (error) -> String in
            if let authError = error as? AuthError {
                switch authError {
                case .cancel:
                    return "ログインをキャンセルしました"
                case .alreadyUser:
                    return "既にログインされているユーザです"
                case .unknown:
                    return "不明なエラーが発生しました: \(error.localizedDescription)"
                }
            } else {
                return "ログインエラーが発生しました: \(error.localizedDescription)"
            }
        }.observeOn(MainScheduler.instance).asObservable()

        addTrigger
            .subscribe(onNext: {
                _ = router.login().subscribe(onNext: nil)
            })
            .disposed(by: disposeBag)

        // インスタンスの選択で通知される
        NotificationCenter.default.rx.notification(.selectedMastodonInstance)
            .compactMap { $0.object as? Instance }
            .map { $0.name }
            .bind(to: hostname)
            .disposed(by: disposeBag)

        // ホストネームが設定されたのでインスタンスにアプリケーションを登録する
        hostname.bind(to: registerAppAction.inputs).disposed(by: disposeBag)

        subscribeActions()

        Observable.merge(registerAppAction.errors, authorizeAction.errors, loginAppAction.errors, verifyTokenAction.errors)
            .map { if case let .underlyingError(error) = $0 { return error } else { return AuthError.unknown } }
            .bind(to: loginErrorTrigger)
            .disposed(by: disposeBag)
    }

    // MARK: - Private method

    private func subscribeActions() {
        // インスタンスにアプリケーションの登録がされたのでブラウザでログインをする
        registerAppAction.elements.withLatestFrom(hostname) { ($1, $0) }.bind(to: authorizeAction.inputs).disposed(by: disposeBag)

        // ブラウザを使ったログインが成功したのでアクセストークンを取得する
        authorizeAction.elements
            .withLatestFrom(Observable.combineLatest(hostname, registerAppAction.elements)) { ($1.0, .init(code: $0, application: $1.1)) }
            .bind(to: loginAppAction.inputs)
            .disposed(by: disposeBag)

        // アクセストークンが取得できたのでユーザを取得する
        loginAppAction.elements
            .withLatestFrom(hostname) { ($1, $0.accessToken) }
            .bind(to: verifyTokenAction.inputs)
            .disposed(by: disposeBag)

        // ユーザを取得できたのでRealmに保存する
        verifyTokenAction.elements
            .withLatestFrom(Observable.combineLatest(hostname, registerAppAction.elements, loginAppAction.elements)) { ($0, $1.0, $1.1, $1.2.accessToken) }
            .subscribe(onNext: { [weak self] (account, hostname, application, accessToken) in
                let realm = try! Realm(configuration: realmConfiguration)
                if realm.objects(User.self)
                    .filter("serviceID = %@ AND serviceType = %@", account.id, Service.mastodon.rawValue)
                    .first != nil {
                    // すでに登録されている
                    self?.loginErrorTrigger.accept(AuthError.alreadyUser)
                    return
                }

                let user = User.createMastodon(account)
                let secret = SecretCredential.createMastodon(application: application, accessToken: accessToken, hostname: hostname, user: user)

                try! realm.write {
                    realm.add(user, update: .error)
                    realm.add(secret, update: .error)
                }
                self?.loginSuccessTrigger.accept(user.screenName)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - AccountManageViewModelInput

extension MastodonAccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput

extension MastodonAccountManageViewModel: AccountManageViewModelOutput {}
