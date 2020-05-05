//
//  TweetPostViewModel.swift
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

final class TweetPostViewModel: PostViewModelType {

    let postText: PublishRelay<String> = .init()
    let dismissTrigger: PublishRelay<Void> = .init()
    let postTrigger: PublishRelay<Void> = .init()
    let changeAccount: PublishRelay<Void> = .init()
    let selectAttachment: PublishRelay<Void> = .init()
    let title: Observable<String>
    let initialPostText: Observable<String>
    let account: Observable<User>
    let attachment: Observable<UIImage?>

    var inputs: PostViewModelInput { return self }
    var outputs: PostViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let didEdit: BehaviorRelay<Bool> = .init(value: false)
    private let selectAccount: BehaviorRelay<User>
    private let attachmentImage: BehaviorRelay<UIImage?> = .init(value: nil)

    init(router: PostRoutable, item: MPMediaItem) {
        title = .just("ツイート")
        initialPostText = .just(Service.getPostText(.twitter, item: item))
        let realm = try! Realm(configuration: realmConfiguration)
        let user = realm.objects(User.self).filter("serviceType = %@ AND isDefault = %@", Service.twitter.rawValue, true).first!
        selectAccount = .init(value: user)
        account = selectAccount.asObservable()
        attachment = attachmentImage.asObservable().share(replay: 2, scope: .whileConnected)

        if UserDefaults.standard.bool(forKey: .isWithImage) {
            attachmentImage.accept(item.artwork?.image)
        }

        postText.skip(2).map { _ in true }.distinctUntilChanged().bind(to: didEdit).disposed(by: disposeBag)

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
    }
}

// MARK: - PostViewModelInput

extension TweetPostViewModel: PostViewModelInput {}

// MARK: - PostViewModelOutput

extension TweetPostViewModel: PostViewModelOutput {}
