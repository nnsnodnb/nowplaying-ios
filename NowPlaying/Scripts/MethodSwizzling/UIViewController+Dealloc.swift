//
//  UIViewController+Dealloc.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/09/14.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import DeallocationChecker
import UIKit

extension UIViewController {

    class func swizzleViewDidDisappear() {
        let fromMethod = class_getInstanceMethod(self, #selector(viewDidDisappear(_:)))!
        let toMethod = class_getInstanceMethod(self, #selector(overrideViewDidDisappear(_:)))!
        method_exchangeImplementations(fromMethod, toMethod)
    }

    @objc private func overrideViewDidDisappear(_ animated: Bool) {
        overrideViewDidDisappear(animated)
        #if DEBUG
        DeallocationChecker.shared.checkDeallocation(of: self)
        #endif
    }
}
