//
//  ShadowButton.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/09.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit

final class ShadowButton: UIButton {

    @IBInspectable var shadowRadius: CGFloat = 3

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.shadowColor = R.color.artworkShadowColor()!.cgColor
        layer.shadowOffset = .zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.5
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            layer.shadowColor = R.color.artworkShadowColor()!.cgColor
        }
    }
}
