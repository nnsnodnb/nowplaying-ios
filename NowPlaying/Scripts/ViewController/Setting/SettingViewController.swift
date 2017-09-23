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

class SettingViewController: FormViewController {

    fileprivate let userDefaults = UserDefaults.standard

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

    fileprivate func setupForm() {
        form
            +++ Section()
            <<< ButtonRow() {
                $0.title = "ログイン"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .left
                cell.textLabel?.textColor = UIColor.black
                cell.accessoryType = .disclosureIndicator
            }).onCellSelection({ (cell, row) in
                row.deselect()
                SVProgressHUD.show()
                AuthManager.shared.login() {
                    SVProgressHUD.showSuccess(withStatus: "ログインしました")
                    SVProgressHUD.dismiss(withDelay: 0.5)
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
    }

    // MARK: - UIBarButtonItem target

    func onTapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
