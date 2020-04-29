//
//  Realm+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxSwift

extension Results {

    func response() -> Observable<Results<Element>> {
        return .create { (observer) -> Disposable in
            MainScheduler.ensureExecutingOnScheduler()

            let token = self.observe { (change) in
                switch change {
                case .initial(let collections):
                    observer.onNext(collections)
                case .update(let collections, deletions: _, insertions: _, modifications: _):
                    observer.onNext(collections)
                case .error(let error):
                    observer.onError(error)
                }
            }

            return Disposables.create {
                token.invalidate()
            }
        }
    }
}
