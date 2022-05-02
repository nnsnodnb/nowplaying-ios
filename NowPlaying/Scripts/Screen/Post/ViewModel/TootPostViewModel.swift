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

    private lazy var postTootAction: Action<(SecretCredential, String, Data?), Status> = .init {
        return MastodonKitRequest(secret: $0.0).rx.postToot(status: $0.1, media: $0.2)
    }

    required init(router: PostRoutable, item: MPMediaItem, screenshot: UIImage) {
        self.router = router
        super.init(router: router, item: item, screenshot: screenshot)

        postTrigger
            .withLatestFrom(Observable.combineLatest(account, postText, attachment)) { ($1.0, $1.1, $1.2) }
            .map { ($0.secretCredentials.first!, $1, $2?.jpegData(compressionQuality: 1)) }
            .do(onNext: { (_) in
                SVProgressHUD.show()
            })
            .bind(to: postTootAction.inputs)
            .disposed(by: disposeBag)

        postTootAction.elements
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (_) in
                SVProgressHUD.dismiss()
                router.dismissConfirm(didEdit: false)
            })
            .disposed(by: disposeBag)

        postTootAction.errors
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (actionError) in
                print(actionError)
                SVProgressHUD.showError(withStatus: "エラーが発生しました")
            })
            .disposed(by: disposeBag)
    }
}
