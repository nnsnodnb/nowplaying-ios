//
//  SwiftPrint.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {

    #if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(output, separator: separator, terminator: terminator)
    #endif
}
