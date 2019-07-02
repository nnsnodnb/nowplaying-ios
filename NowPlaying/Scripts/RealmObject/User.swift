//
//  User.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RealmSwift

final class User: Object {

    @objc dynamic var id: Int = 1
    @objc dynamic var serviceID: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var screenName: String = ""
    @objc dynamic var serviceType: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }

    class func getLastestPrimaryKey() -> Int? {
        let realm = try? Realm(configuration: realmConfiguration)
        return realm?.objects(User.self).sorted(byKeyPath: "id", ascending: false).last?.id
    }

    convenience init(serviceID: String, name: String="", screenName: String="", serviceType: Service) {
        self.init()
        let latestPrimaryKey = User.getLastestPrimaryKey() ?? 0
        self.id = latestPrimaryKey + 1
        self.serviceID = serviceID
        self.name = name
        self.screenName = screenName
        self.serviceType = serviceType.rawValue
    }
}
