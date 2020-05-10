//
//  PreviewRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/09.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol PreviewViewer: UIViewController {}

protocol PreviewRoutable: AnyObject {

    init(view: PreviewViewer)
    func dismiss()
}

final class PreviewRouter: PreviewRoutable {

    private(set) weak var view: PreviewViewer!

    init(view: PreviewViewer) {
        self.view = view
    }

    func dismiss() {
        view.dismiss(animated: true, completion: nil)
    }
}
