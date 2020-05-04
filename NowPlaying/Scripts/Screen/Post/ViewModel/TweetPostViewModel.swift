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

    let postText: BehaviorRelay<String> = .init(value: "")
    let dismissTrigger: PublishRelay<Void> = .init()
    let postTrigger: PublishRelay<Void> = .init()
    let title: Observable<String>

    var inputs: PostViewModelInput { return self }
    var outputs: PostViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let didEdit: BehaviorRelay<Bool> = .init(value: false)

    init(router: PostRoutable) {
        title = .just("ツイート")

        postText.skip(1).map { _ in true }.distinctUntilChanged().bind(to: didEdit).disposed(by: disposeBag)

        dismissTrigger
            .withLatestFrom(didEdit)
            .subscribe(onNext: {
                router.dismissConfirm(didEdit: $0)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PostViewModelInput

extension TweetPostViewModel: PostViewModelInput {}

// MARK: - PostViewModelOutput

extension TweetPostViewModel: PostViewModelOutput {}
