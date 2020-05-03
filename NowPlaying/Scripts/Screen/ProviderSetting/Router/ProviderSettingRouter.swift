//
//  ProviderSettingRouter.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

protocol ProviderSettingViewer: UIViewController {}

protocol ProviderSettingRoutable: AnyObject {

    func present(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)
}

final class TwitterSettingRouter: ProviderSettingRoutable {

    private(set) weak var view: ProviderSettingViewer!

    init(view: ProviderSettingViewer) {
        self.view = view
    }

    func present(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        view.present(viewControllerToPresent, animated: animated, completion: completion)
    }
}

final class MastodonSettingRouter: ProviderSettingRoutable {

    private(set) weak var view: ProviderSettingViewer!

    init(view: ProviderSettingViewer) {
        self.view = view
    }

    func present(viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        view.present(viewControllerToPresent, animated: animated, completion: completion)
    }
}
