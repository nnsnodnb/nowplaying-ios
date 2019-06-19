//
//  SearchMastodonTableViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/19.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - SearchMastodonTableViewModelOutput

protocol SearchMastodonTableViewModelOutput {

}

// MARK: - SearchMastodonTableViewModelType

protocol SearchMastodonTableViewModelType {

    var outputs: SearchMastodonTableViewModelOutput { get }
    init()
}

final class SearchMastodonTableViewModel: SearchMastodonTableViewModelType {

    var outputs: SearchMastodonTableViewModelOutput { return self }

    init() {

    }
}

// MARK: - SearchMastodonTableViewModelOutput

extension SearchMastodonTableViewModel: SearchMastodonTableViewModelOutput {

}
