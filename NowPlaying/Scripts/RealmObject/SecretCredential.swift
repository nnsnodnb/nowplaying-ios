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

    @objc dynamic var id: Int = 1
    @objc dynamic var consumerKey: String = ""
    @objc dynamic var consumerSecret: String = ""
    @objc dynamic var authToken: String = ""
    @objc dynamic var authTokenSecret: String = ""
    @objc dynamic var domainName: String = ""
    @objc dynamic var user: User?

    override class func primaryKey() -> String? {
        return "id"
    }

    class func getLastestPrimaryKey() -> Int? {
        let realm = try? Realm(configuration: realmConfiguration)
        return realm?.objects(SecretCredential.self).sorted(byKeyPath: "id", ascending: false).first?.id
    }

    convenience init(consumerKey: String="", consumerSecret: String="", authToken: String="",
                     authTokenSecret: String="", domainName: String="", user: User?) {
        self.init()
        let latestPrimaryKey = SecretCredential.getLastestPrimaryKey() ?? 0
        self.id = latestPrimaryKey + 1
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
        self.authToken = authToken
        self.authTokenSecret = authTokenSecret
        self.domainName = domainName
        self.user = user
    }
}
