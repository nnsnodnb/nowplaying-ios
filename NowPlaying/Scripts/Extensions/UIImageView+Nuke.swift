//
//  UIImageView+Nuke.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/25.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Nuke
import UIKit

extension UIImageView {

    func setImage(with url: URL) {
        loadImage(with: url, into: self)
    }
}
