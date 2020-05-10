//
//  TweetPostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import Foundation
import MediaPlayer
import RealmSwift
import RxCocoa
import RxSwift
import SVProgressHUD
import SwifteriOS

final class TweetPostViewModel: PostViewModel {

    override var service: Service { return .twitter }

    private let disposeBag = DisposeBag()

    private lazy var postTweetAction: Action<(SecretCredential, String, Data?), JSON> = .init {
        return SwifterRequest(secretCredential: $0.0).rx.postTweet(status: $0.1, media: $0.2)
    }

    required init(router: PostRoutable, item: MPMediaItem, screenshot: UIImage) {
        super.init(router: router, item: item, screenshot: screenshot)

        postTrigger
            .withLatestFrom(Observable.combineLatest(account, postText, attachment)) { $1 }
            .map { ($0.0.secretCredentials.first!, $0.1, $0.2?.jpegData(compressionQuality: 1)) }
            .do(onNext: { (_) in
                SVProgressHUD.show()
                router.closeKeyboard()
            })
            .bind(to: postTweetAction.inputs)
            .disposed(by: disposeBag)

        postTweetAction.elements
            .subscribe(onNext: { (_) in
                SVProgressHUD.dismiss()
                router.dismissConfirm(didEdit: false)
            })
            .disposed(by: disposeBag)

        postTweetAction.errors
            .subscribe(onNext: { (actionError) in
                print(actionError)
                let string: String
                defer { SVProgressHUD.showError(withStatus: "エラーが発生しました: \(string)") }
                switch actionError {
                case .notEnabled:
                    string = "一度この画面を閉じてください"
                case .underlyingError(let error):
                    string = error.localizedDescription
                }
            })
            .disposed(by: disposeBag)
    }
}
