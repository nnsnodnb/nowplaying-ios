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
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = 0.5
    }
}
