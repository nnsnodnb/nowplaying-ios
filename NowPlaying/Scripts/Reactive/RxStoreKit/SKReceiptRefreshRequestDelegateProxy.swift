//
//  SKReceiptRefreshRequestDelegateProxy.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/07.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RxCocoa
import RxSwift
import StoreKit

class SKReceiptRefreshRequestDelegateProxy: DelegateProxy<SKReceiptRefreshRequest, SKRequestDelegate>, DelegateProxyType, SKRequestDelegate {

    init(parentObject: SKReceiptRefreshRequest) {
        super.init(parentObject: parentObject, delegateProxy: SKReceiptRefreshRequestDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { SKReceiptRefreshRequestDelegateProxy(parentObject: $0) }
    }

    static func currentDelegate(for object: SKReceiptRefreshRequest) -> SKRequestDelegate? {
        return object.delegate
    }

    static func setCurrentDelegate(_ delegate: SKRequestDelegate?, to object: SKReceiptRefreshRequest) {
        object.delegate = delegate
    }

    let responseSubject = PublishSubject<SKProductsResponse>()

    func requestDidFinish(_ request: SKRequest) {
        _forwardToDelegate?.requestDidFinish?(request)
        responseSubject.onCompleted()
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        _forwardToDelegate?.request?(request, didFailWithError: error)
        responseSubject.onError(error)
    }

    deinit {
        responseSubject.on(.completed)
    }
}
