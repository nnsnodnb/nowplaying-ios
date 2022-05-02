//
//  TwitterAccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxRealm
import RxSwift
import SwifteriOS

final class TwitterAccountManageViewModel: AccountManageViewModel {

    override var service: Service { return .twitter }

    var input: AccountManageViewModelInput { return self }
    var output: AccountManageViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    required init(router: AccountManageRoutable) {
        super.init(router: router)
        addTrigger.bind(to: login).disposed(by: disposeBag)
    }

    private var login: Binder<Void> {
        return .init(self) { (base, _) in
            let onError: (Error) -> Void = { [weak base] (error) in
                base?.loginErrorTrigger.accept(error)
            }

            _ = base.router.login()
                .subscribe(onNext: { [weak base] (token) in
                    let realm = try! Realm(configuration: realmConfiguration)
                    guard realm.objects(User.self).filter("serviceID = %@ AND serviceType = %@", token.userID, "twitter").first == nil else {
                        // すでに登録されている
                        base?.loginErrorTrigger.accept(AuthError.alreadyUser)
                        return
                    }
                    let swifter = Swifter.nowPlaying(oauthToken: token.key, oauthTokenSecret: token.secret)
                    _ = swifter.rx.showUser(tag: .id(token.userID))
                        .subscribe(onSuccess: { twitterUser in
                            let user = User(serviceID: twitterUser.userID, name: twitterUser.name, screenName: twitterUser.screenName,
                                            iconURLString: twitterUser.iconURLString, service: .twitter)
                            let secret = SecretCredential.createTwitter(authToken: token.key, authTokenSecret: token.secret, user: user)

                            let realm = try! Realm(configuration: realmConfiguration)
                            try! realm.write {
                                realm.add(user, update: .error)
                                realm.add(secret, update: .error)
                            }

                            base?.loginSuccessTrigger.accept(user.screenName)

                        }, onFailure: onError)

                }, onError: onError)
        }
    }
}
