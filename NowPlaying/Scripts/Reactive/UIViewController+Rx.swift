//
//  UIViewController+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/05.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIViewController {

    @available(iOS 13.0, *)
    var isModalInPresentation: Binder<Bool> {
        return .init(base) { (viewController, isModalInPresentation) in
            viewController.isModalInPresentation = isModalInPresentation
        }
    }
}
