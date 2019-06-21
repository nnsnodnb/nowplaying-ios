//
//  SearchMastodonTableViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/19.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import Foundation
import RxCocoa
import RxSwift

// MARK: - SearchMastodonTableViewModelInput

struct SearchMastodonTableViewModelInput {

    let searchBarText: Observable<String?>
}

// MARK: - SearchMastodonTableViewModelOutput

protocol SearchMastodonTableViewModelOutput {

    var mastodonInstances: Observable<[Instance]> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<Error> { get }
}

// MARK: - SearchMastodonTableViewModelType

protocol SearchMastodonTableViewModelType {

    var outputs: SearchMastodonTableViewModelOutput { get }
    init(inputs: SearchMastodonTableViewModelInput)
}

final class SearchMastodonTableViewModel: SearchMastodonTableViewModelType {

    let mastodonInstances: Observable<[Instance]>
    let isLoading: Observable<Bool>
    let error: Observable<Error>

    var outputs: SearchMastodonTableViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let searchAction: Action<String, [Instance]>

    init(inputs: SearchMastodonTableViewModelInput) {
        searchAction = Action {
            Session.shared.rx.response(InstancesSearchRequest(query: $0))
                .map { $0.instances }
        }
        let response = BehaviorRelay<[Instance]>(value: [])
        mastodonInstances = response.asObservable()

        isLoading = searchAction.executing.startWith(false)

        error = searchAction.errors
            .map { _ in NSError(domain: "Network error", code: 0, userInfo: nil) }
            .asObservable()

        searchAction.elements
            .bind(to: response)
            .disposed(by: disposeBag)

        inputs.searchBarText
            .compactMap { $0 }
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
    }
}

// MARK: - SearchMastodonTableViewModelOutput

extension SearchMastodonTableViewModel: SearchMastodonTableViewModelOutput {}
