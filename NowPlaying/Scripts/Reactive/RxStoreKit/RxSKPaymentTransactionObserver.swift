//
//  RxSKPaymentTransactionObserver.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/07.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RxCocoa
import RxSwift
import StoreKit

class RxSKPaymentTransactionObserver {

    static let shared = RxSKPaymentTransactionObserver()

    init() {
        SKPaymentQueue.default().add(observer)
    }

    deinit {
        SKPaymentQueue.default().remove(observer)
    }

    let observer = Observer()

    class Observer: NSObject, SKPaymentTransactionObserver {

        let updatedTransactionSubject = PublishSubject<SKPaymentTransaction>()
        let removedTransactionSubject = PublishSubject<SKPaymentTransaction>()
        let restoreCompletedTransactionsFailedWithErrorSubject = PublishSubject<(SKPaymentQueue, Error)>()
        let paymentQueueRestoreCompletedTransactionsFinishedSubject = PublishSubject<SKPaymentQueue>()
        let updatedDownloadSubject = PublishSubject<SKDownload>()

        func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            transactions.forEach { transaction in
                updatedTransactionSubject.onNext(transaction)
            }
        }

        func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
            transactions.forEach { transaction in
                removedTransactionSubject.onNext(transaction)
            }
        }

        func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
            restoreCompletedTransactionsFailedWithErrorSubject.onNext((queue, error))
        }

        func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
            paymentQueueRestoreCompletedTransactionsFinishedSubject.onNext(queue)
        }

        func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
            downloads.forEach { download in
                updatedDownloadSubject.onNext(download)
            }
        }
    }

    var rx_updatedTransaction: Observable<SKPaymentTransaction> {
        return observer.updatedTransactionSubject
    }

    var rx_removedTransaction: Observable<SKPaymentTransaction> {
        return observer.removedTransactionSubject
    }

    var rx_restoreCompletedTransactionsFailedWithError: Observable<(SKPaymentQueue, Error)> {
        return observer.restoreCompletedTransactionsFailedWithErrorSubject
    }

    var rx_paymentQueueRestoreCompletedTransactionsFinished: Observable<SKPaymentQueue> {
        return observer.paymentQueueRestoreCompletedTransactionsFinishedSubject
    }

    var rx_updatedDownload: Observable<SKDownload> {
        return observer.updatedDownloadSubject
    }
}
