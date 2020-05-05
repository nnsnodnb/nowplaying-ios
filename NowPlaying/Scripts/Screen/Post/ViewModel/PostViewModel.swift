//
//  PostViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/04.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer
import RealmSwift
import RxCocoa
import RxSwift

protocol PostViewModelInput {

    var postText: PublishRelay<String> { get }
    var dismissTrigger: PublishRelay<Void> { get }
    var postTrigger: PublishRelay<Void> { get }
    var changeAccount: PublishRelay<Void> { get }
    var selectAttachment: PublishRelay<Void> { get }
    var addAttachment: PublishRelay<Void> { get }
    var didAttemptToDismiss: PublishRelay<Void> { get }
}

protocol PostViewModelOutput {

    var title: Observable<String> { get }
    var initialPostText: Observable<String> { get }
    var didChangePostText: Observable<Bool> { get }
    var account: Observable<User> { get }
    var attachment: Observable<UIImage?> { get }
}

protocol PostViewModelType {

    var inputs: PostViewModelInput { get }
    var outputs: PostViewModelOutput { get }
    init(router: PostRoutable, item: MPMediaItem, screenshot: UIImage)
}

class PostViewModel: PostViewModelType {

    /* Inputs */
    let postText: PublishRelay<String> = .init()
    let dismissTrigger: PublishRelay<Void> = .init()
    let postTrigger: PublishRelay<Void> = .init()
    let changeAccount: PublishRelay<Void> = .init()
    let selectAttachment: PublishRelay<Void> = .init()
    let addAttachment: PublishRelay<Void> = .init()
    let didAttemptToDismiss: PublishRelay<Void> = .init()
    /* Outputs */
    let attachment: Observable<UIImage?>

    var inputs: PostViewModelInput { return self }
    var outputs: PostViewModelOutput { return self }
    var title: Observable<String> {
        return service == .twitter ? .just("ツイート") : .just("トゥート")
    }
    var initialPostText: Observable<String> {
        return .just(Service.getPostText(service, item: item))
    }
    var didChangePostText: Observable<Bool> {
        return didEdit.filter { $0 }.asObservable()
    }
    var account: Observable<User> {
        return selectAccount.asObservable()
    }
    var service: Service { fatalError("Required override") }

    private let item: MPMediaItem
    private let screenshot: UIImage
    private let disposeBag = DisposeBag()
    private let didEdit: BehaviorRelay<Bool> = .init(value: false)
    private let attachmentImage: BehaviorRelay<UIImage?> = .init(value: nil)

    private lazy var selectAccount: BehaviorRelay<User> = {
        let realm = try! Realm(configuration: realmConfiguration)
        let user = realm.objects(User.self).filter("serviceType = %@ AND isDefault = %@", service.rawValue, true).first!
        return .init(value: user)
    }()

    required init(router: PostRoutable, item: MPMediaItem, screenshot: UIImage) {
        self.item = item
        self.screenshot = screenshot
        attachment = attachmentImage.asObservable().share(replay: 2, scope: .whileConnected)

        postText.skip(2).take(1).map { _ in true }.bind(to: didEdit).disposed(by: disposeBag)

        subscribeInputs(router: router)

        let key: UserDefaults.Key = service == .twitter ? .isWithImage : .isMastodonWithImage
        if UserDefaults.standard.bool(forKey: key) { attachmentImage.accept(item.artwork?.image) }

        postText.skip(2).map { _ in true }.distinctUntilChanged().bind(to: didEdit).disposed(by: disposeBag)
    }

    private func subscribeInputs(router: PostRoutable) {
        dismissTrigger
            .withLatestFrom(didEdit)
            .subscribe(onNext: {
                router.dismissConfirm(didEdit: $0)
            })
            .disposed(by: disposeBag)

        changeAccount
            .subscribe(onNext: {

            })
            .disposed(by: disposeBag)

        selectAttachment
            .withLatestFrom(attachmentImage)
            .compactMap { $0 }
            .subscribe(onNext: {
                router.presentAttachmentActions(withImage: $0) { [unowned self] in
                    self.attachmentImage.accept(nil)
                }
            })
            .disposed(by: disposeBag)

        addAttachment
            .subscribe(onNext: {
                router.presentAddAttachmentActions { [unowned self] in
                    switch $0 {
                    case .artwork:
                        self.attachmentImage.accept(self.item.artwork?.image)
                    case .screenshot:
                        self.attachmentImage.accept(self.screenshot)
                        return
                    }
                }
            })
            .disposed(by: disposeBag)

        didAttemptToDismiss
            .subscribe(onNext: {
                router.dismissConfirm(didEdit: true)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PostViewModelInput

extension PostViewModel: PostViewModelInput {}

// MARK: - PostViewModelOutput

extension PostViewModel: PostViewModelOutput {}
