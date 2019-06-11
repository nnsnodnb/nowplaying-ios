//
//  AppInfoManager.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/05/26.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

final class AppInfoManager: RequestFactory {

    override var url: URL {
        return URL(string: "https://nowplayingios.firebaseapp.com/app_info.json")!
    }
}
