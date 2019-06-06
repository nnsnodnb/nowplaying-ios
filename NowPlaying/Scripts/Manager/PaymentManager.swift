//
//  PaymentManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/03/30.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import StoreKit
import SVProgressHUD

final class PaymentManager {

    static let shared = PaymentManager()

    private let disposeBag = DisposeBag()

    enum Product {
        case hideAdmob
        case autoTweet

        static func create(withProductIdentifier identifier: String) -> Product {
            if identifier == Product.hideAdmob.productIdentifier {
                return .hideAdmob
            } else if identifier == Product.autoTweet.productIdentifier {
                return .autoTweet
            } else {
                fatalError("unknown product identifier")
            }
        }

        var productIdentifier: String {
            switch self {
            case .hideAdmob:
                return "moe.nnsnodnb.NowPlaying.hideAdMob"
            case .autoTweet:
                return "moe.nnsnodnb.NowPlaying.autoTweet"
            }
        }

        func finishPurchased() {
            switch self {
            case .hideAdmob:
                UserDefaults.set(true, forKey: .isPurchasedRemoveAdMob)
            case .autoTweet:
                UserDefaults.set(true, forKey: .isAutoTweetPurchase)
            }
        }
    }

    enum BuyTransactionState {
        case purchasing
        case purchased
    }

    func buyProduct(_ product: Product) -> Observable<BuyTransactionState> {
        return Observable<BuyTransactionState>.create { [unowned self] (observer) -> Disposable in
            let productRequest = SKProductsRequest(productIdentifiers: Set([product.productIdentifier]))
            productRequest.rx.productsRequest
                .flatMap { Observable.from($0.products) }
                .flatMap { SKPaymentQueue.default().rx.add(product: $0, shouldVerify: true) }
                .subscribe(onNext: { (transaction) in
                    switch transaction.transactionState {
                    case .failed:
                        observer.onError(NSError(domain: "transaction error", code: 0, userInfo: ["transaction": transaction]))
                    case .purchased:
                        observer.onNext(.purchased)
                        observer.onCompleted()
                    case .purchasing:
                        observer.onNext(.purchasing)
                    case .restored, .deferred:
                        break
                    @unknown default:
                        break
                    }
                }, onError: { (error) in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            productRequest.start()
            return Disposables.create()
        }
    }

    func restore() -> Observable<[Product]> {
        return Observable<[Product]>.create { [unowned self] (observer) -> Disposable in
            SKPaymentQueue.default().rx.restoreCompletedTransactions()
                .subscribe(onNext: { (queue) in
                    let products = queue.transactions.map { Product.create(withProductIdentifier: $0.payment.productIdentifier) }
                    observer.onNext(products)
                    observer.onCompleted()
                }, onError: { (error) in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }
}
