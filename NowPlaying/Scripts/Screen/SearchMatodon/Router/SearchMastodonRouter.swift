//
//  SearchMastodonRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol SearchMastodonViewer: UIViewController {}

protocol SearchMastodonRoutable: AnyObject {

    init(view: SearchMastodonViewer)
}

final class SearchMastodonRouter: SearchMastodonRoutable {

    private(set) weak var view: SearchMastodonViewer!

    init(view: SearchMastodonViewer) {
        self.view = view
    }
}
