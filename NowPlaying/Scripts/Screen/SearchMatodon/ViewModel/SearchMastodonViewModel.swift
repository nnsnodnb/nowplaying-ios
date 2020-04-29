//
//  SearchMastodonViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Action
import APIKit
import Foundation
import RxCocoa
import RxSwift

protocol SearchMastodonViewModelInput {

}

protocol SearchMastodonViewModelOutput {

    var dataSource: Observable<[InstanceAnimatableSectionModel]> { get }
}

protocol SearchMastodonViewModelType {

    var input: SearchMastodonViewModelInput { get }
    var output: SearchMastodonViewModelOutput { get }
    init(router: SearchMastodonRoutable)
}

final class SearchMastodonViewModel: SearchMastodonViewModelType {

    let dataSource: Observable<[InstanceAnimatableSectionModel]>

    var input: SearchMastodonViewModelInput { return self }
    var output: SearchMastodonViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let instances: BehaviorRelay<[Instance]> = .init(value: [])

    private lazy var fetchListAction: Action<Void, InstanceResponse> = .init {
        return Session.shared.rx.response(InstanceListRequest())
    }
    private lazy var fetchSearchAction: Action<String, InstanceResponse> = .init {
        return Session.shared.rx.response(InstanceSearchRequest(query: $0))
    }

    init(router: SearchMastodonRoutable) {
        dataSource = instances.map { [.init(model: "", items: $0)] }.asObservable()

        fetchListAction.elements.map { $0.instances }.bind(to: instances).disposed(by: disposeBag)
        fetchSearchAction.elements.map { $0.instances }.bind(to: instances).disposed(by: disposeBag)

        fetchListAction.execute(())
    }
}

// MARK: - SearchMastodonViewModelInput

extension SearchMastodonViewModel: SearchMastodonViewModelInput {}

// MARK: - SearchMastodonViewModelOutput

extension SearchMastodonViewModel: SearchMastodonViewModelOutput {}
