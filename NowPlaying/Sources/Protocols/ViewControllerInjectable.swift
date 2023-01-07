//
//  ViewControllerInjectable.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import UIKit

protocol ViewControllerInjectable: UIViewController {
    associatedtype Dependency

    init(dependency: Dependency, environment: EnvironmentProtocol)
}

extension ViewControllerInjectable where Dependency == Void {
    init(dependency: Dependency = (), environment: EnvironmentProtocol) {
        self.init(dependency: dependency, environment: environment)
    }
}
