//
//  TweetPostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer
import RealmSwift
import RxCocoa
import RxSwift

final class TweetPostViewModel: PostViewModel {

    override var service: Service { return .twitter }
}
