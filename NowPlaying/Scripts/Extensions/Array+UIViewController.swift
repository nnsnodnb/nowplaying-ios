//
//  Array+UIViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/29.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import UIKit

extension Array where Element == UIViewController {

    func get<T: UIViewController>(type: T.Type) -> T? {
        return first(where: { $0 is T }) as? T
    }
}
