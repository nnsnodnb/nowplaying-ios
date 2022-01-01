//
//  ViewControllerInjectable.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import UIKit

protocol ViewControllerInjectable: UIViewController {
    associatedtype Dependency

    init(dependency: Dependency)
}
