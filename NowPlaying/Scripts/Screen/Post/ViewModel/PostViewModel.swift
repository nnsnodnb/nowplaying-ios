//
//  PostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer
import RxCocoa
import RxSwift

protocol PostViewModelInput {

    var postText: BehaviorRelay<String> { get }
    var dismissTrigger: PublishRelay<Void> { get }
    var postTrigger: PublishRelay<Void> { get }
    var changeAccount: PublishRelay<Void> { get }
}

protocol PostViewModelOutput {

    var title: Observable<String> { get }
}

protocol PostViewModelType {
    var inputs: PostViewModelInput { get }
    var outputs: PostViewModelOutput { get }
    init(router: PostRoutable, item: MPMediaItem)
}
