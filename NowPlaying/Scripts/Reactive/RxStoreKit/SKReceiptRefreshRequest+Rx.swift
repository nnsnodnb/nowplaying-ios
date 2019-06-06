//
//  SKReceiptRefreshRequest+Rx.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/07.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RxCocoa
import RxSwift
import StoreKit

extension SKReceiptRefreshRequest {

    func createRxDelegateProxy() -> SKReceiptRefreshRequestDelegateProxy {
        return SKReceiptRefreshRequestDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: SKReceiptRefreshRequest {

    var delegate: DelegateProxy<SKReceiptRefreshRequest, SKRequestDelegate> {
        return SKReceiptRefreshRequestDelegateProxy.proxy(for: base)
    }

    var request: Completable {
        return SKReceiptRefreshRequestDelegateProxy.proxy(for: base).responseSubject.ignoreElements()
    }
}
