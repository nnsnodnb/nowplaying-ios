//
//  Constants.swift
//  NowPlayingTests
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

private final class Dummy {}

let iconImagePath: String = {
    return Bundle(for: Dummy.self).path(forResource: "icon", ofType: "png")!
}()

let iconImage: UIImage = {
    return UIImage(contentsOfFile: iconImagePath)!
}()
