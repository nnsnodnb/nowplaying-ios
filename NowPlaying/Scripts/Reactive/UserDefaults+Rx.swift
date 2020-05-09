//
//  UserDefaults+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: UserDefaults {

    func change<Element>(type: Element.Type, key: UserDefaults.Key, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<Element?> {
        return base.rx.observe(type, key.rawValue, options: options, retainSelf: retainSelf)
    }
}
