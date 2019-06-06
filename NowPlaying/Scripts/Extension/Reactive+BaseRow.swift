//
//  Reactive+BaseRow.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import Eureka
import RxCocoa
import RxSwift

extension BaseRow: ReactiveCompatible {}

extension Reactive where Base: BaseRow, Base: RowType {

    var value: ControlProperty<Base.Cell.Value?> {
        let source = Observable<Base.Cell.Value?>.create { [weak base] observer in
            if let _base = base {
                observer.onNext(_base.value)
                _base.onChange {
                    observer.onNext($0.value)
                }
            }
            return Disposables.create {
                observer.onCompleted()
            }
        }
        let bindingObserver = BindableObserver(container: base) { (row, value) in
            row.value = value
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
