//
//  SettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/22.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import Eureka
import SVProgressHUD
import TwitterKit
import StoreKit

class SettingViewController: FormViewController {

    fileprivate let userDefaults = UserDefaults.standard

    fileprivate var isLogin = false

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    fileprivate func setup() {
        setupNavigationbar()
        setupIsLogin()
        setupForm()
    }

    fileprivate func setupNavigationbar() {
        guard navigationController != nil else {
            return
        }
        title = "設定"
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onTapCloseButton(_:)))
        navigationItem.rightBarButtonItem = closeButton
    }

    fileprivate func setupIsLogin() {
        isLogin = Twitter.sharedInstance().sessionStore.session() != nil
    }

    fileprivate func setupForm() {
        form
            +++ Section()
            <<< ButtonRow() { [unowned self] in
                $0.title = !self.isLogin ? "ログイン" : "ログアウト"
                $0.tag = "login"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }).onCellSelection({ (cell, row) in
                row.deselect()
                SVProgressHUD.show()
                if self.isLogin {
                    AuthManager.shared.logout {
                        SVProgressHUD.showSuccess(withStatus: "ログアウトしました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        self.isLogin = !self.isLogin
                        DispatchQueue.main.async {
                            cell.textLabel?.text = "ログイン"
                        }
                    }
                } else {
                    AuthManager.shared.login() {
                        SVProgressHUD.showSuccess(withStatus: "ログインしました")
                        SVProgressHUD.dismiss(withDelay: 0.5)
                        self.isLogin = !self.isLogin
                        DispatchQueue.main.async {
                            cell.textLabel?.text = "ログアウト"
                        }
                    }
                }
            })

            +++ Section()
            <<< SwitchRow() { [unowned self] in
                $0.title = "アートワークを添付"
                $0.value = self.userDefaults.bool(forKey: UserDefaultsKey.isWithImage.rawValue)
            }.onChange({ (row) in
                self.userDefaults.set(row.value!, forKey: UserDefaultsKey.isWithImage.rawValue)
                self.userDefaults.synchronize()
            })

            +++ Section()
            <<< ButtonRow() {
                $0.title = "レビューする"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }).onCellSelection({ [unowned self] (cell, row) in
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    // TODO: - AppStoreのアプリIDの付加
                    if let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=") {
                        let alert = UIAlertController(title: nil, message: "AppStoreを起動します", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            UIApplication.shared.openURL(url)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
    }

    // MARK: - UIBarButtonItem target

    func onTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
