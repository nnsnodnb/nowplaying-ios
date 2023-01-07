//
//  EnvironmentProtocol.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import Foundation

protocol EnvironmentProtocol {
    var application: UIApplicationProtocol { get }
    var screen: UIScreenProtocol { get }
    var window: UIWindowProtocol { get }
}
