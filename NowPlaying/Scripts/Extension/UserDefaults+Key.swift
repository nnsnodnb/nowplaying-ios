//
//  UserDefaults+Key.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2018/04/14.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

extension UserDefaults {

    class func set(_ obj: Any?, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(obj, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func removeObject(forKey key: UserDefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }

    class func bool(forKey key: UserDefaultsKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    class func integer(forKey key: UserDefaultsKey) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }

    class func string(forKey key: UserDefaultsKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    class func object(forKey key: UserDefaultsKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
}
