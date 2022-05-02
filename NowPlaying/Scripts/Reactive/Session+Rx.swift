//
//  Session+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import APIKit
import RxCocoa
import RxSwift
import UIKit

extension Session: ReactiveCompatible {}

extension Reactive where Base: Session {

    func response<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = .main) -> Single<Request.Response> {
        return .create { [weak base] observer -> Disposable in

            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }

            let task = base?.send(request, callbackQueue: callbackQueue) { (result) in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.failure(error))
                }

                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }

            return Disposables.create {
                task?.cancel()

                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
}
