//
//  PostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

protocol PostViewModelInput {}

protocol PostViewModelOutput {}

protocol PostViewModelType {
    var inputs: PostViewModelInput { get }
    var outputs: PostViewModelOutput { get }
    init(router: PostRoutable)
}
