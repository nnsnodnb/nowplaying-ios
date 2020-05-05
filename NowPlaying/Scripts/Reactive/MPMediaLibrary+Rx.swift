//
//  MPMediaLibrary+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/05.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer
import RxCocoa
import RxSwift

extension Reactive where Base: MPMediaLibrary {

    static func requestAuthorization() -> Observable<MPMediaLibraryAuthorizationStatus> {
        if MPMediaLibrary.authorizationStatus() == .authorized {
            return .just(.authorized, scheduler: MainScheduler.instance)
        }
        return .create { (observer) -> Disposable in
            MPMediaLibrary.requestAuthorization { (status) in
                observer.onNext(status)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
