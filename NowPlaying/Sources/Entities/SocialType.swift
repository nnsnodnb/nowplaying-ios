//
//  SocialType.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

enum SocialType: String {
    case twitter
    case mastodon

    // MARK: - Properties
    var title: String {
        switch self {
        case .twitter:
            return "Twitter"
        case .mastodon:
            return "Mastodon"
        }
    }
    var image: UIImage {
        switch self {
        case .twitter:
            return Asset.Assets.icTwitter.image
        case .mastodon:
            return Asset.Assets.icMastodon.image
        }
    }
}
