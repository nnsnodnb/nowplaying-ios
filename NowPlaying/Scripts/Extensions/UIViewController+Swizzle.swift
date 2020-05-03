//
//  UIViewController+Swizzle.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/03.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import DeallocationChecker
import UIKit

#if DEBUG

extension UIViewController {

    class func swizzleViewDidDisappear() {
        let fromMethod = class_getInstanceMethod(self, #selector(viewDidDisappear(_:)))!
        let toMethod = class_getInstanceMethod(self, #selector(overrideViewDidDisappear(_:)))!
        method_exchangeImplementations(fromMethod, toMethod)
    }

    @objc private func overrideViewDidDisappear(_ animated: Bool) {
        overrideViewDidDisappear(animated)
        DeallocationChecker.shared.checkDeallocation(of: self)
    }
}

#endif
