//
//  TweetViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct TweetViewModelInput {

}

// MARK: - TweetViewModelOutput

protocol TweetViewModelOutput {

}

// MARK: - TweetViewModelType

protocol TweetViewModelType {

    var outputs: TweetViewModelOutput { get }

    init(inputs: TweetViewModelInput)
}

final class TweetViewModel: TweetViewModelType {

    var outputs: TweetViewModelOutput { return self }

    init(inputs: TweetViewModelInput) {

    }
}

// MARK: - TweetViewModelType

extension TweetViewModel: TweetViewModelOutput {

}
