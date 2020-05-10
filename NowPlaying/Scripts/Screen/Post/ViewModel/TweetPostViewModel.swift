//
//  TweetPostViewModel.swift
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

final class TweetPostViewModel: PostViewModel {

    override var service: Service { return .twitter }

    private let disposeBag = DisposeBag()

    required init(router: PostRoutable, item: MPMediaItem, screenshot: UIImage) {
        super.init(router: router, item: item, screenshot: screenshot)

        postTrigger
            .withLatestFrom(postText)
            .subscribe(onNext: { (text) in
                print(text)
            })
            .disposed(by: disposeBag)
    }
}
