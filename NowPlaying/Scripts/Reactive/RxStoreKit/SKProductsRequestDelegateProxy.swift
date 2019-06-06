//
//  SKProductsRequestDelegateProxy.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/07.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RxCocoa
import RxSwift
import StoreKit

class SKProductsRequestDelegateProxy: DelegateProxy<SKProductsRequest, SKProductsRequestDelegate>, DelegateProxyType, SKProductsRequestDelegate {

    init(parentObject: SKProductsRequest) {
        super.init(parentObject: parentObject, delegateProxy: SKProductsRequestDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { SKProductsRequestDelegateProxy(parentObject: $0) }
    }

    static func currentDelegate(for object: SKProductsRequest) -> SKProductsRequestDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: SKProductsRequestDelegate?, to object: SKProductsRequest) {
        object.delegate = delegate
    }

    let responseSubject = PublishSubject<SKProductsResponse>()

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        _forwardToDelegate?.productsRequest(request, didReceive: response)
        responseSubject.onNext(response)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        _forwardToDelegate?.request?(request, didFailWithError: error)
        responseSubject.onError(error)
    }

    deinit {
        responseSubject.on(.completed)
    }
}

