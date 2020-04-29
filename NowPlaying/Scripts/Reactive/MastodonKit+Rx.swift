//
//  MastodonKit+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MastodonKit
import RxCocoa
import RxSwift

extension Client: ReactiveCompatible {}

extension Reactive where Base == Client {

    func response<Model: Codable>(_ request: MastodonKit.Request<Model>) -> Single<Model> {
        return .create { (observer) -> Disposable in
            self.base.run(request) { (result) in
                switch result {
                case .success(let data, _):
                    observer(.success(data))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create()
        }
    }
}
