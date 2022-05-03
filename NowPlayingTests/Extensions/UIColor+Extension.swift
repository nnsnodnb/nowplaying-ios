//
//  UIColor+Extension.swift
//  NowPlayingTests
//
//  Created by Yuya Oka on 2022/05/04.
//

import UIKit

extension UIColor {
    func image(_ size: CGSize = .init(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            self.setFill()
            context.fill(.init(origin: .zero, size: size))
        }
    }
}
