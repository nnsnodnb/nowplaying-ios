//
//  TootPostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

final class TootPostViewModel: PostViewModelType {

    var inputs: PostViewModelInput { return self }
    var outputs: PostViewModelOutput { return self }

    init(router: PostRoutable) {

    }
}

// MARK: - PostViewModelInput

extension TootPostViewModel: PostViewModelInput {}

// MARK: - PostViewModelOutput

extension TootPostViewModel: PostViewModelOutput {}
