//
//  SNSSettingBaseViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/07/22.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAnalytics
import StoreKit
import SVProgressHUD

class SNSSettingBaseViewController: FormViewController {

    var screenName: String!
    var viewControllerName: String!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SKPaymentQueue.default().transactions.count <= 0 {
            return
        }
        SKPaymentQueue.default().transactions
            .filter { $0.transactionState != .purchasing }
            .forEach { SKPaymentQueue.default().finishTransaction($0) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName(screenName, screenClass: viewControllerName)
        Analytics.logEvent("screen_open", parameters: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Public method

    func setupForm() {
        // Please override
    }
}
