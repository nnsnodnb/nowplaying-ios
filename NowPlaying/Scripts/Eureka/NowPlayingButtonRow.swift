//
//  NowPlayingButtonRow.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/08.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import Eureka
import RxCocoa
import RxSwift

typealias NowPlayingButtonRow = ButtonRowOf<String>

final class ButtonRowOf<T>: _ButtonRowOf<T>, RowType where T: Equatable {

    required init(tag: String?) {
        super.init(tag: tag)

        cellUpdate { (cell, _) in
            cell.textLabel?.textAlignment = .left
            if #available(iOS 13.0, *) {
                cell.textLabel?.textColor = .label
            } else {
                cell.textLabel?.textColor = .black
            }
            cell.accessoryType = .disclosureIndicator
        }
    }
}

extension BaseRow: ReactiveCompatible {}

extension Reactive where Base: BaseRow, Base: RowType {

    func onCellSelection() -> Observable<(Base.Cell, Base)> {
        return .create { [weak base] (observer) -> Disposable in
            base?.onCellSelection { (cell, row) in
                observer.onNext((cell, row))
            }
            return Disposables.create()
        }
    }
}
