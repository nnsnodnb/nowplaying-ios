//
//  SettingProviderViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import Foundation

protocol SettingProviderViewModelInput: AnyObject {
}

protocol SettingProviderViewModelOutput: AnyObject {
    var title: String { get }
    var dataSource: [SettingProviderViewController.SectionModel] { get }
}

protocol SettingProviderViewModelType: AnyObject {
    var inputs: SettingProviderViewModelInput { get }
    var outputs: SettingProviderViewModelOutput { get }
}

final class SettingProviderViewModel: SettingProviderViewModelType {
    // MARK: - Inputs Sources
    // MARK: - Outputs Sources
    let title: String
    let dataSource: [SettingProviderViewController.SectionModel]
    // MARK: - Properties
    var inputs: SettingProviderViewModelInput { return self }
    var outputs: SettingProviderViewModelOutput { return self }

    private let router: SettingProviderRoutable

    // MARK: - Initialize
    init(router: SettingProviderRoutable, socialType: SocialType) {
        self.title = "\(socialType.title)設定"
        self.dataSource = [
            .init(
                model: .socialType(socialType),
                items: [
                    .detail(.accounts),
                    .toggle(.attachImage),
                    .toggle(.auto(socialType))
                ]
            ),
            .init(
                model: .format,
                items: [
                    .textView,
                    .button(.reset)
                ]
            ),
            .init(
                model: .footer,
                items: [
                    .footerNote
                ]
            )
        ]
        self.router = router
    }
}

// MARK: - SettingProviderViewModelInput
extension SettingProviderViewModel: SettingProviderViewModelInput {}

// MARK: - SettingProviderViewModel
extension SettingProviderViewModel: SettingProviderViewModelOutput {}
