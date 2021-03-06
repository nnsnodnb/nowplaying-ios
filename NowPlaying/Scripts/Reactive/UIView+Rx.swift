//
//  UIView+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/09.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIView {

    var transform: Binder<CGAffineTransform> {
        return .init(base) { [weak base] (_, transform) in
            UIView.animate(withDuration: 0.3) {
                base?.transform = transform
            }
        }
    }
}
