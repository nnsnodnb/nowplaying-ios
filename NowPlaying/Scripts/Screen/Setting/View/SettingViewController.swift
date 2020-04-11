//
//  SettingViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Eureka
import RxCocoa
import RxSwift
import UIKit

final class SettingViewController: FormViewController {

    private let disposeBag = DisposeBag()

    private(set) var viewModel: SettingViewModelType!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SettingViewController: SettingViewer {}

extension SettingViewController {

    struct Dependency {
        let viewModel: SettingViewModelType
    }

    func inject() {
        
    }
}
