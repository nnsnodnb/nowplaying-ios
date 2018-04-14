//
//  PaymentManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/03/30.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation
import StoreKit

class PaymentManager: NSObject {

    deinit {
        print(#function)
    }

    class var shared: PaymentManager {
        struct Static {
            static let shared = PaymentManager()
        }
        return Static.shared
    }

    // 購入完了のNotification
    static let paymentCompletedNotification = "PaymentCompletedNotification"

    // 購入失敗のNotification
    static let paymentErrorNotification = "PaymentErrorNotification"

    // トランザクションが残っているか
    static var isRemainTransaction: Bool {
        return UserDefaults.standard.bool(forKey: "IsRemainTransaction")
    }

    weak var delegate: PaymentManagerProtocol?

    private var productsRequest: SKProductsRequest!

    func startTransactionObserve() {
        SKPaymentQueue.default().add(self)
    }

    func stopTransactionObseve() {
        SKPaymentQueue.default().remove(self)
    }

    func startProductRequest(_ productIds: Set<String>) -> SKProductsRequest {
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest.delegate = self
        productsRequest.start()

        return productsRequest!
    }

    @discardableResult
    func buyProduct(_ product: SKProduct) -> Bool {
        guard SKPaymentQueue.canMakePayments() else {
            return false
        }

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)

        return true
    }

    func startRestore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - Private method

    /* Complete Payment */
    private func complete(transaction: SKPaymentTransaction) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PaymentManager.paymentCompletedNotification),
                                        object: transaction)
        delegate?.finish(success: transaction)

        SKPaymentQueue.default().finishTransaction(transaction)
    }

    /* Failure Payment */
    private func failed(transaction: SKPaymentTransaction) {
        if let error: NSError = transaction.error as NSError? {
            if error.code == SKError.paymentCancelled.rawValue {
                print("Cancel")
            } else {
                print("\(error.localizedDescription)")
            }
        }

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PaymentManager.paymentErrorNotification),
                                        object: transaction)
        delegate?.finishPayment(failed: transaction)

        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

// MARK: - SKPaymentTransactionObserver

extension PaymentManager: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased: // 購入処理完了
                complete(transaction: transaction)
            case .failed: // 購入処理失敗
                failed(transaction: transaction)
            case .restored: // リストア
                complete(transaction: transaction)
            case .deferred: // 保留中
                break
            case .purchasing: // 購入処理開始
                UserDefaults.standard.set(true, forKey: "IsRemainTransaction")
                UserDefaults.standard.synchronize()
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        UserDefaults.standard.set(false, forKey: "IsRemainTransaction")
        UserDefaults.standard.synchronize()
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.finishRestore(queue: queue, restoreCompletedTransactionsFailedWithError: error)
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.finishRestore(queue: queue)
    }
}

// MARK: - SKProductsRequestDelegate

extension PaymentManager: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        for invalidIds in response.invalidProductIdentifiers {
            print(invalidIds)
        }

        delegate?.finish(request: request, products: response.products)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        delegate?.finish(request: request, didFailWithError: error)
    }
}
