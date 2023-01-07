//
//  SettingProviderRouter.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import UIKit

protocol SettingProviderRoutable: Routable {
}

final class SettingProviderRouter: SettingProviderRoutable {
    // MARK: - Properties
    private(set) weak var viewController: UIViewController?

    private let environment: EnvironmentProtocol
    private let socialType: SocialType

    // MARK: - Initialize
    init(environment: EnvironmentProtocol, socialType: SocialType) {
        self.environment = environment
        self.socialType = socialType
    }

    func inject(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}
