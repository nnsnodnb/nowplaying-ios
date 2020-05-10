//
//  TootPostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import Foundation
import MastodonKit
import MediaPlayer
import RealmSwift
import RxCocoa
import RxSwift
import SVProgressHUD

final class TootPostViewModel: PostViewModel {

    override var service: Service { return .mastodon }

    private let disposeBag = DisposeBag()
    private let router: PostRoutable

    private lazy var postMediaAction: Action<(SecretCredential, Data), Attachment> = .init {
        return Client.create(baseURL: $0.0.domainName, accessToken: $0.0.authToken).rx.response(Media.upload(data: $0.1))
    }
    private lazy var postTootAction: Action<(SecretCredential, String, [String]), Status> = .init {
        return Client.create(baseURL: $0.0.domainName, accessToken: $0.0.authToken)
            .rx.response(Statuses.create(status: $0.1, mediaIDs: $0.2))
    }

    private var preparePostToot: Binder<(SecretCredential, String, Data?)> {
        return .init(self) {
            defer {
                SVProgressHUD.show()
            }
            $0.router.closeKeyboard()
            if let data = $1.2 {
                $0.postMediaAction.execute(($1.0, data))
            } else {
                $0.postTootAction.execute(($1.0, $1.1, []))
            }
        }
    }

    required init(router: PostRoutable, item: MPMediaItem, screenshot: UIImage) {
        self.router = router
        super.init(router: router, item: item, screenshot: screenshot)

        postTrigger
            .withLatestFrom(Observable.combineLatest(account, postText, attachment)) { ($1.0, $1.1, $1.2) }
            .map { ($0.secretCredentials.first!, $1, $2?.jpegData(compressionQuality: 1)) }
            .bind(to: preparePostToot)
            .disposed(by: disposeBag)

        postMediaAction.elements
            .observeOn(MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(account, postText)) { ($1.0, $1.1, $0) }
            .map { ($0.secretCredentials.first!, $1, [$2.id]) }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .bind(to: postTootAction.inputs)
            .disposed(by: disposeBag)

        postTootAction.elements
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (_) in
                SVProgressHUD.dismiss()
                router.dismissConfirm(didEdit: false)
            })
            .disposed(by: disposeBag)

        Observable.merge([postMediaAction.errors, postTootAction.errors])
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (actionError) in
                print(actionError)
                SVProgressHUD.showError(withStatus: "エラーが発生しました")
            })
            .disposed(by: disposeBag)
    }
}
