//
//  PostRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol PostViewer: UIViewController {}

protocol PostRoutable: AnyObject {

}

final class PostRouter: PostRoutable {

    private(set) weak var view: PostViewer!

    init(view: PostViewer) {
        self.view = view
    }
}
