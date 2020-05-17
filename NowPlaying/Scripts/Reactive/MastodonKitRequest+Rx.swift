//
//  MastodonKitRequest+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/17.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import MastodonKit
import RxCocoa
import RxSwift
import UIKit

extension MastodonKitRequest: ReactiveCompatible {}

extension Reactive where Base == MastodonKitRequest {

    func postToot(status: String, media: Data? = nil) -> Observable<Status> {
        return .create { (observer) -> Disposable in
            self.base.postToot(status: status, media: media) { (result) in
                switch result {
                case .success(let status, _):
                    observer.onNext(status)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
