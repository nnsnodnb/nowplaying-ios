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
}

// MARK: - SearchMastodonTableViewModelType

protocol SearchMastodonTableViewModelType {

    var outputs: SearchMastodonTableViewModelOutput { get }
    init(inputs: SearchMastodonTableViewModelInput)
}

final class SearchMastodonTableViewModel: SearchMastodonTableViewModelType {

    let mastodonInstances: Observable<[Instance]>
    let isLoading: Observable<Bool>

    var outputs: SearchMastodonTableViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let initialAction: Action<Void, [Instance]>
    private let searchAction: Action<String, [Instance]>

    init(inputs: SearchMastodonTableViewModelInput) {
        initialAction = Action {
            Session.shared.rx.response(InstanceListRequest()).map { $0.instances }
        }
        searchAction = Action {
            Session.shared.rx.response(InstancesSearchRequest(query: $0)).map { $0.instances }
        }

        let response = BehaviorRelay<[Instance]>(value: [])
        mastodonInstances = response.asObservable()

        isLoading = searchAction.executing.startWith(false)

        initialAction.elements
            .bind(to: response)
            .disposed(by: disposeBag)
        searchAction.elements
            .skip(1)
            .bind(to: response)
            .disposed(by: disposeBag)

        inputs.searchBarText
            .subscribe(onNext: { [weak self] in
                if let text = $0, !text.isEmpty {
                    self?.searchAction.inputs.onNext(text)
                } else {
                    self?.initialAction.inputs.onNext(())
                }
            })
            .disposed(by: disposeBag)

        initialAction.inputs.onNext(())
    }
}

// MARK: - SearchMastodonTableViewModelOutput

extension SearchMastodonTableViewModel: SearchMastodonTableViewModelOutput {}
