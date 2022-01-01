//
//  Routable.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import UIKit

protocol Routable {
    var viewController: UIViewController? { get }

    func inject(_ viewController: UIViewController)
}
