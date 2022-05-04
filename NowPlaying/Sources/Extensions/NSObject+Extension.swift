//
//  NSObject+Extension.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import Foundation

extension NSObject {
    static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}
