//
//  SKProductsRequest+Rx.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/07.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RxCocoa
import RxSwift
import StoreKit

extension SKProductsRequest {

    func createRxDelegateProxy() -> SKProductsRequestDelegateProxy {
        return SKProductsRequestDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: SKProductsRequest {

    var delegate: DelegateProxy<SKProductsRequest, SKProductsRequestDelegate> {
        return SKProductsRequestDelegateProxy.proxy(for: base)
    }

    var productsRequest: Observable<SKProductsResponse> {
        return SKProductsRequestDelegateProxy.proxy(for: base).responseSubject.asObservable()
    }
}
