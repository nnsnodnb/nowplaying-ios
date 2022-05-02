//
//  SwifterRequest+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/10.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import SwifteriOS

extension SwifterRequest: ReactiveCompatible {}

extension Reactive where Base == SwifterRequest {

    func postTweet(status: String, media: Data? = nil) -> Observable<JSON> {
        return .create { observer -> Disposable in
            self.base.postTweet(status: status, media: media, success: {
                observer.onNext($0)
                observer.onCompleted()
            }, failure: {
                observer.onError($0)
            })

            return Disposables.create()
        }
    }
}
