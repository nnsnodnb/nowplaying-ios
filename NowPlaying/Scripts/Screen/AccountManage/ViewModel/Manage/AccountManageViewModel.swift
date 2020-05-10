//
//  AccountManageViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import RealmSwift
import RxCocoa
import RxDataSources
import RxRealm
import RxSwift

protocol AccountManageViewModelInput {

    var addTrigger: PublishRelay<Void> { get }
    var editTrigger: PublishRelay<Void> { get }
    var deleteTrigger: PublishRelay<User> { get }
    var cellSelected: PublishRelay<User> { get }
}

protocol AccountManageViewModelOutput {

    var dataSource: Observable<(AnyRealmCollection<User>, RealmChangeset?)> { get }
    var loginSuccess: Observable<String> { get }
    var loginError: Observable<String> { get }
}

protocol AccountManageViewModelType: AnyObject {

    var inputs: AccountManageViewModelInput { get }
    var outputs: AccountManageViewModelOutput { get }
    var service: Service { get }
}

class AccountManageViewModel: AccountManageViewModelType {

    let addTrigger: PublishRelay<Void> = .init()
    let editTrigger: PublishRelay<Void> = .init()
    let deleteTrigger: PublishRelay<User> = .init()
    let cellSelected: PublishRelay<User> = .init()
    let router: AccountManageRoutable
    let loginSuccessTrigger: PublishRelay<String> = .init()
    let loginErrorTrigger: PublishRelay<Error> = .init()

    var inputs: AccountManageViewModelInput { return self }
    var outputs: AccountManageViewModelOutput { return self }
    var service: Service { fatalError("Require override") }
    var dataSource: Observable<(AnyRealmCollection<User>, RealmChangeset?)> {
        let realm = try! Realm(configuration: realmConfiguration)
        let results = realm.objects(User.self).filter("serviceType = %@", service.rawValue).sorted(byKeyPath: "id", ascending: true)
        return Observable.changeset(from: results)
    }
    var loginSuccess: Observable<String> {
        return loginSuccessTrigger.map { "@\($0)" }.observeOn(MainScheduler.instance).asObservable()
    }
    var loginError: Observable<String> {
        return loginErrorTrigger.map { $0.authErrorDescription }.observeOn(MainScheduler.instance).asObservable()
    }

    private let disposeBag = DisposeBag()

    private lazy var serviceStore: BehaviorRelay<Service> = .init(value: service)

    required init(router: AccountManageRoutable) {
        self.router = router

        editTrigger
            .subscribe(onNext: {
                router.setEditing()
            })
            .disposed(by: disposeBag)

        deleteTrigger.map { $0.id }.bind(to: deleteUser).disposed(by: disposeBag)

        cellSelected
            .withLatestFrom(serviceStore) { ($0, $1) }
            .subscribe(onNext: { (user, service) in
                let realm = try! Realm(configuration: realmConfiguration)
                let others = realm.objects(User.self).filter("id != %@ AND serviceType = %@", user.id, service.rawValue)
                try! realm.write {
                    user.isDefault = true
                    others.setValue(false, forKey: "isDefault")
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private properties

    private var deleteUser: Binder<Int> {
        return .init(self) { (base, identifier) in
            let realm = try! Realm(configuration: realmConfiguration)
            guard let user = realm.object(ofType: User.self, forPrimaryKey: identifier) else { return }
            let secrets = user.secretCredentials

            let defaultUser: User?
            if user.isDefault {
                defaultUser = realm.objects(User.self)
                    .filter("id != %@ AND serviceType = %@", user.id, base.service.rawValue).first
            } else {
                defaultUser = nil
            }

            try! realm.write {
                realm.delete(secrets)
                realm.delete(user)
                defaultUser?.isDefault = true
            }

            if let newDefaultUser = defaultUser, newDefaultUser.isDefault {
                base.router.completeChangedDefaultAccount(user: newDefaultUser)
            }
        }
    }
}

// MARK: - AccountManageViewModelInput

extension AccountManageViewModel: AccountManageViewModelInput {}

// MARK: - AccountManageViewModelOutput
extension AccountManageViewModel: AccountManageViewModelOutput {}
