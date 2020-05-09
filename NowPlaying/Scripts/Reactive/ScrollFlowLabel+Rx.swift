//
//  ScrollFlowLabel+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/09.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import ScrollFlowLabel

extension Reactive where Base: ScrollFlowLabel {

    var text: Binder<String?> {
        return .init(base) { (label, text) in
            label.text = text
        }
    }
}
