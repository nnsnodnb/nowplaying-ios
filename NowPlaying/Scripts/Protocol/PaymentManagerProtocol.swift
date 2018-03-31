//
//  PaymentManagerProtocol.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/03/30.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

protocol PaymentManagerProtocol: class {
    func finish(request: SKProductsRequest, products: [SKProduct])
    func finish(request: SKRequest, didFailWithError: Error)
    func finish(success paymentTransaction: SKPaymentTransaction)
    func finishPayment(failed paymentTransaction: SKPaymentTransaction)
    func finishRestore(queue: SKPaymentQueue)
    func finishRestore(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError: Error)
}
