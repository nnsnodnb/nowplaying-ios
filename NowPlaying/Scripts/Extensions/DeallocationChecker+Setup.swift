//
//  DeallocationChecker+Setup.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/03.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import DeallocationChecker
import UIKit

#if DEBUG

extension DeallocationChecker {

    func setup() {
        setup(with: .callback {
            if $0 == .leaked && Bundle(for: $1) == .main {
                print("🚨 MemoryLeaked: \($1)")
            }
        })
        UIViewController.swizzleViewDidDisappear()
    }
}

#endif
