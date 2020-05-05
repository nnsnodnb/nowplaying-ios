//
//  TootPostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer
import RealmSwift
import RxCocoa
import RxSwift

final class TootPostViewModel: PostViewModelType {

    let postText: PublishRelay<String> = .init()
    let dismissTrigger: PublishRelay<Void> = .init()
    let postTrigger: PublishRelay<Void> = .init()
    let changeAccount: PublishRelay<Void> = .init()
    let title: Observable<String>
    let initialPostText: Observable<String>
    let account: Observable<User>

    var inputs: PostViewModelInput { return self }
    var outputs: PostViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let didEdit: BehaviorRelay<Bool> = .init(value: false)
    private let selectAccount: BehaviorRelay<User>

    init(router: PostRoutable, item: MPMediaItem) {
        title = .just("トゥート")
        initialPostText = .just(Service.getPostText(.mastodon, item: item))
        let realm = try! Realm(configuration: realmConfiguration)
        let user = realm.objects(User.self).filter("serviceType = %@ AND isDefault = %@", Service.mastodon.rawValue, true).first!
        selectAccount = .init(value: user)
        account = selectAccount.asObservable()

        postText.skip(2).map { _ in true }.distinctUntilChanged().bind(to: didEdit).disposed(by: disposeBag)

        dismissTrigger
            .withLatestFrom(didEdit)
            .subscribe(onNext: {
                router.dismissConfirm(didEdit: $0)
            })
            .disposed(by: disposeBag)

        changeAccount
            .subscribe(onNext: {

            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PostViewModelInput

extension TootPostViewModel: PostViewModelInput {}

// MARK: - PostViewModelOutput

extension TootPostViewModel: PostViewModelOutput {}
