//
//  MastodonSettingRouter.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import UIKit

protocol MastodonSettingRoutable: Routable {
}

final class MastodonSettingRouter: MastodonSettingRoutable {
    // MARK: - Properties
    private(set) weak var viewController: UIViewController?

    private let environment: EnvironmentProtocol

    // MARK: - Initialize
    init(environment: EnvironmentProtocol) {
        self.environment = environment
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
