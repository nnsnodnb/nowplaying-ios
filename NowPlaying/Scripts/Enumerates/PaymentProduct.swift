//
//  PaymentProduct.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/06.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import StoreKit

enum PaymentProduct: String {

    case autoTweet = "moe.nnsnodnb.NowPlaying.autoTweet"
    case hideAdMob = "moe.nnsnodnb.NowPlaying.hideAdMob"

    var userDefaultsKey: UserDefaults.Key {
        switch self {
        case .autoTweet:
            return .isAutoTweetPurchase
        case .hideAdMob:
            return .isPurchasedRemoveAdMob
        }
    }

    static func restore() -> Observable<[PaymentProduct]> {
        return SKPaymentQueue.default().rx.restoreCompletedTransactions()
            .map { $0.transactions.compactMap { PaymentProduct(rawValue: $0.payment.productIdentifier)} }
    }

    func finishPurchased() {
        UserDefaults.standard.set(true, forKey: userDefaultsKey)
    }

    func buyProduct() -> Observable<BuyTransactionState> {
        let request = SKProductsRequest(productIdentifiers: Set([rawValue]))
        return .create { (observer) -> Disposable in
            _ = request.rx.productsRequest
                .flatMap { Observable.from($0.products) }
                .flatMap { SKPaymentQueue.default().rx.add(product: $0, shouldVerify: true) }
                .subscribe(onNext: { (transaction) in
                    switch transaction.transactionState {
                    case .failed:
                        observer.onError(NSError(domain: "transaction error", code: 0, userInfo: ["transaction": transaction]))
                    case .purchased, .restored:
                        observer.onNext(.purchased)
                        observer.onCompleted()
                    case .purchasing:
                        observer.onNext(.purchasing)
                    case .deferred:
                        break
                    @unknown default:
                        break
                    }
                }, onError: { (error) in
                    observer.onError(error)
                })

            request.start()

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
