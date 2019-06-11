//
//  Reactive+Session.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import APIKit
import Foundation
import RxCocoa
import RxSwift

extension Session: ReactiveCompatible {}

extension Reactive where Base: Session {

    func response<T: Request>(_ request: T) -> Single<T.Response> {
        return Single<T.Response>.create { [weak base] (observer) -> Disposable in
            let task = base?.send(request, callbackQueue: .main) { (result) in
                switch result {
                case .success(let value):
                    observer(.success(value))
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create { task?.cancel() }
        }
    }
}
