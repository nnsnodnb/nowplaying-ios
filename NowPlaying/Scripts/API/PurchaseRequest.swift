//
//  PurchaseRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/27.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Alamofire

class PurchaseRequest: RequestFactory {

    let receiptData: String

    init(receiptData: String) {
        self.receiptData = receiptData
    }

    override var url: URL {
        #if DEBUG
            return URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        #else
            return URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        #endif
    }

    override var method: HTTPMethod {
        return .post
    }

    override var dictionary: Parameters {
        return [
            "receipt-data": receiptData
        ]
    }
}
