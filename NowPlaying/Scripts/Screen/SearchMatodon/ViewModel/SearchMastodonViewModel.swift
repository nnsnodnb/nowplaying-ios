//
//  SearchMastodonViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

protocol SearchMastodonViewModelInput {

}

protocol SearchMastodonViewModelOutput {

}

protocol SearchMastodonViewModelType {

    var input: SearchMastodonViewModelInput { get }
    var output: SearchMastodonViewModelOutput { get }
    init(router: SearchMastodonRoutable)
}

final class SearchMastodonViewModel: SearchMastodonViewModelType {

    var input: SearchMastodonViewModelInput { return self }
    var output: SearchMastodonViewModelOutput { return self }

    init(router: SearchMastodonRoutable) {

    }
}

// MARK: - SearchMastodonViewModelInput

extension SearchMastodonViewModel: SearchMastodonViewModelInput {}

// MARK: - SearchMastodonViewModelOutput

extension SearchMastodonViewModel: SearchMastodonViewModelOutput {}
