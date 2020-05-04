//
//  TweetPostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

final class TweetPostViewModel: PostViewModelType {

    var inputs: PostViewModelInput { return self }
    var outputs: PostViewModelOutput { return self }

    init(router: PostRoutable) {

    }
}

// MARK: - PostViewModelInput

extension TweetPostViewModel: PostViewModelInput {}

// MARK: - PostViewModelOutput

extension TweetPostViewModel: PostViewModelOutput {}
