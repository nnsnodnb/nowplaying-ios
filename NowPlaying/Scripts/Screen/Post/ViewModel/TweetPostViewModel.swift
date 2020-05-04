//
//  TweetPostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final class TweetPostViewModel: PostViewModelType {

    let dismissTrigger: PublishRelay<Void> = .init()
    let postTrigger: PublishRelay<Void> = .init()
    let title: Observable<String>

    var inputs: PostViewModelInput { return self }
    var outputs: PostViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(router: PostRoutable) {
        title = .just("ツイート")

        dismissTrigger
            .subscribe(onNext: {
                router.dismissConfirm(didEdit: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PostViewModelInput

extension TweetPostViewModel: PostViewModelInput {}

// MARK: - PostViewModelOutput

extension TweetPostViewModel: PostViewModelOutput {}
