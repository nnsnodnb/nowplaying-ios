//
//  Realm+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/03.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

extension Results {

    func response() -> Observable<Results<Element>> {
        return Observable<Results<Element>>.create { (observer) -> Disposable in
            MainScheduler.ensureExecutingOnScheduler()

            let token = self.observe { (change) in
                switch change {
                case .initial(let collectionType):
                    observer.onNext(collectionType)
                case .update(let collectionType, deletions: _, insertions: _, modifications: _):
                    observer.onNext(collectionType)
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
