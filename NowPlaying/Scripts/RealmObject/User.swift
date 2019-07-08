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
    @objc dynamic var iconURLString: String = ""
    @objc dynamic var serviceType: String = ""
    @objc dynamic var isDefault: Bool = false

    let secretCredentials = LinkingObjects(fromType: SecretCredential.self, property: "user")

    override class func primaryKey() -> String? {
        return "id"
    }

    class func getLastestPrimaryKey() -> Int? {
        let realm = try? Realm(configuration: realmConfiguration)
        return realm?.objects(User.self).sorted(byKeyPath: "id", ascending: false).first?.id
    }

    convenience init(serviceID: String, name: String="", screenName: String="", iconURL: URL, serviceType: Service) {
        self.init()
        let latestPrimaryKey = User.getLastestPrimaryKey() ?? 0
        id = latestPrimaryKey + 1
        self.serviceID = serviceID
        self.name = name
        self.screenName = screenName
        iconURLString = iconURL.absoluteString
        self.serviceType = serviceType.rawValue
        isDefault = !User.isExists(service: serviceType)
    }
}

extension User {

    var iconURL: URL {
        return URL(string: iconURLString)!
    }

    var isTwitetrUser: Bool {
        guard let service = Service(rawValue: serviceType) else {
            return false
        }
        return service == .twitter
    }

    var isMastodonUser: Bool {
        return !isTwitetrUser
    }

    func isExists() throws -> Bool {
        let realm = try Realm(configuration: realmConfiguration)
        return !realm.objects(User.self).filter("serviceID = %@", serviceID).isEmpty
    }
}

extension User {

    class func isExists(service: Service) -> Bool {
        let realm = try! Realm(configuration: realmConfiguration)
        return !realm.objects(User.self).filter("serviceType = %@", service.rawValue).isEmpty
    }
}
