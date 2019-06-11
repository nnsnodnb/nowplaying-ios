//
//  SwiftPrint.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/12.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation

func print(_ object: Any) {
    #if RELEASE
    #else
    Swift.print(object)
    #endif
}
