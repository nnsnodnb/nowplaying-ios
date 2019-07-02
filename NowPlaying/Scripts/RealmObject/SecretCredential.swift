//
//  SecretCredential.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RealmSwift

final class SecretCredential: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var consumerKey: String = ""
    @objc dynamic var consumerSecret: String = ""
    @objc dynamic var authToken: String = ""
    @objc dynamic var authTokenSecret: String = ""
    @objc dynamic var user: User?

    override class func primaryKey() -> String? {
        return "id"
    }
}
