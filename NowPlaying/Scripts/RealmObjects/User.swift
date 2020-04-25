//
//  User.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Differentiator
import Foundation
import RealmSwift
import RxCocoa
import RxSwift

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

    override class func ignoredProperties() -> [String] {
        return ["iconURL", "isTwitterUser", "isMastodonUser"]
    }

    class func getLastestPrimaryKey() -> Int? {
        let realm = try? Realm(configuration: realmConfiguration)
        return realm?.objects(User.self).sorted(byKeyPath: "id", ascending: false).first?.id
    }

    convenience init(serviceID: String, name: String="", screenName: String="", iconURLString: String, service: Service) {
        self.init()
        let latestPrimaryKey = User.getLastestPrimaryKey() ?? 0
        id = latestPrimaryKey + 1
        self.serviceID = serviceID
        self.name = name
        self.screenName = screenName
        self.iconURLString = iconURLString
        serviceType = service.rawValue
        isDefault = !User.isExists(service: service)
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

    static func changeDefault(toUser user: User) -> Observable<User> {
        if user.isDefault { return .empty() }

        // 自分以外の同じサービスのユーザの isDefault を偽にする
        let realm = try! Realm(configuration: realmConfiguration)
        let users = realm.objects(User.self)
            .filter("id != %@ AND serviceType = %@ AND isDefault = %@", user.id, user.serviceType, true)
        try! realm.write {
            users.setValue(false, forKey: "isDefault")
            user.isDefault = true
        }

        return .just(user)
    }
}

extension User {

    class func isExists(service: Service) -> Bool {
        let realm = try! Realm(configuration: realmConfiguration)
        return !realm.objects(User.self).filter("serviceType = %@", service.rawValue).isEmpty
    }

    class func getDefaultUser(service: Service) -> User? {
        let realm = try! Realm(configuration: realmConfiguration)
        return realm.objects(User.self).filter("serviceType = %@ AND isDefault = %@", service.rawValue, true).first
    }
}

// MARK: - Identifiable

extension User: IdentifiableType {

    var identity: Int {
        return id
    }
}
