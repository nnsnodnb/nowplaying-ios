//
//  TweetViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Action
import APIKit
import Feeder
import FirebaseAnalytics
import Foundation
import RealmSwift
import RxCocoa
import RxSwift
import SVProgressHUD
import Swifter

struct TweetViewModelInput {

    let iconImageButton: Observable<Void>
    let addImageButton: Observable<Void>
    let postContent: PostContent
    let textViewText: Observable<String>
    let viewController: UIViewController
}

// MARK: - TweetViewModelOutput

protocol TweetViewModelOutput {

    var isPostable: Observable<Bool> { get }
    var user: Observable<User> { get }
    var postResult: Observable<Void> { get }
    var newShareImage: Observable<UIImage> { get }
}

// MARK: - TweetViewModelType

protocol TweetViewModelType {

    var outputs: TweetViewModelOutput { get }

    init(inputs: TweetViewModelInput)
    func getCurrentAccount()
    func preparePost(image: UIImage?)
}

final class TweetViewModel: TweetViewModelType {

    var outputs: TweetViewModelOutput { return self }

    private let disposeBag = DisposeBag()
    private let postContent: PostContent
    private let postMessage: BehaviorRelay<String>
    private let postUser: BehaviorRelay<User>
    private let tweetStatusAction: Action<(SecretCredential, String, Data?), JSON>
    private let tootStatusAction: Action<(SecretCredential, String, [String]?), Void>
    private let tootUploadMediaAction: Action<(SecretCredential, Data), MastodonMediaResponse>
    private let _postResult = PublishSubject<Void>()
    private let _newShareImage = PublishSubject<UIImage>()

    private var secretCredential: SecretCredential {
        return postUser.value.secretCredentials.first!
    }

    init(inputs: TweetViewModelInput) {
        let defaultUser = User.getDefaultUser(service: inputs.postContent.service)!
        postUser = BehaviorRelay<User>(value: defaultUser)

        postContent = inputs.postContent
        postMessage = BehaviorRelay<String>(value: inputs.postContent.postMessage)

        // テキストのみ・メディア込みポストアクション (Twitter)
        tweetStatusAction = Action {
            return TwitterPostRequest(credential: $0.0).postTweet(status: $0.1, media: $0.2)
        }
        // テキストのみ・メディア込みポストアクション (Mastodon)
        tootStatusAction = Action {
            return Session.shared.rx.response(MastodonTootRequest(secret: $0.0, status: $0.1, mediaIDs: $0.2))
        }
        // メディアアップロードアクション (Mastodon)
        tootUploadMediaAction = Action {
            return Session.shared.rx.response(MastodonMediaRequest(secret: $0.0, imageData: $0.1))
        }

        subscribeInputs(inputs)
        subscribeAction()
    }

    func getCurrentAccount() {
        postUser.accept(postUser.value)
    }

    func preparePost(image: UIImage?) {
        if let image = image, let data = image.pngData() {
            switch postContent.service {
            case .twitter:
                tweetStatusAction.inputs.onNext((secretCredential, postMessage.value, data))
                Analytics.Tweet.postTweetTwitter(withHasImage: true, content: postContent)
            case .mastodon:
                tootUploadMediaAction.inputs.onNext((secretCredential, data))
                Analytics.Tweet.postTootMastodon(withHasImage: true, content: postContent)
            }
        } else {
            switch postContent.service {
            case .twitter:
                tweetStatusAction.inputs.onNext((secretCredential, postMessage.value, nil))
                Analytics.Tweet.postTweetTwitter(withHasImage: false, content: postContent)
            case .mastodon:
                tootStatusAction.inputs.onNext((secretCredential, postMessage.value, nil))
                Analytics.Tweet.postTootMastodon(withHasImage: false, content: postContent)
            }
        }
    }
}

// MARK: - Private method

extension TweetViewModel {

    private func subscribeInputs(_ inputs: TweetViewModelInput) {
        inputs.textViewText
            .bind(to: postMessage)
            .disposed(by: disposeBag)

        inputs.iconImageButton
            .subscribe(onNext: { [unowned self] in
//                let viewController = AccountManageViewController(service: inputs.postContent.service, screenType: .selection)
//                _ = viewController.selection
//                    .bind(to: self.postUser)
//                inputs.viewController.navigationController?.pushViewController(viewController, animated: true)
                // TODO: AccountManageViewController
            })
            .disposed(by: disposeBag)

        inputs.addImageButton
            .subscribe(onNext: {
                let actionSheet = UIAlertController(title: "画像を追加します", message: "どちらを追加しますか？", preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "アートワーク", style: .default) { [unowned self] (_) in
                    guard let artwork = inputs.postContent.item?.artwork, let image = artwork.image(at: artwork.bounds.size) else {
                        let error = NSError(domain: "moe.nnsnodnb.NowPlaying", code: 404, userInfo: ["detail": "アートワークが見つかりませんでした"])
                        self._newShareImage.onError(error)
                        return
                    }
                    self._newShareImage.onNext(image)
                })
                actionSheet.addAction(UIAlertAction(title: "再生画面のスクリーンショット", style: .default) { (_) in
                    let rect = UIScreen.main.bounds
                    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
                    defer { UIGraphicsEndImageContext() }
                    let context = UIGraphicsGetCurrentContext()!

                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController?.view.layer.render(in: context)

                    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                        let error = NSError(domain: "moe.nnsnodnb.NowPlaying", code: 404, userInfo: ["detail": "アートワークが見つかりませんでした"])
                        self._newShareImage.onError(error)
                        return
                    }
                    self._newShareImage.onNext(image)
                })
                actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                inputs.viewController.present(actionSheet, animated: true, completion: nil)
                Feeder.Selection().selectionChanged()
            })
            .disposed(by: disposeBag)
    }

    private func subscribeAction() {
        tweetStatusAction.elements
            .map { _ in }
            .subscribe(onNext: { [weak self] in
                self?._postResult.onNext(())
                self?._postResult.onCompleted()
            }, onError: { [weak self] (error) in
                self?._postResult.onError(error)
            })
            .disposed(by: disposeBag)

        tootStatusAction.elements
            .map { _ in }
            .subscribe(onNext: { [weak self] in
                self?._postResult.onNext(())
                self?._postResult.onCompleted()
            }, onError: { [weak self] (error) in
                self?._postResult.onError(error)
            })
            .disposed(by: disposeBag)

        tootUploadMediaAction.elements
            .subscribe(onNext: { [weak self] (response) in
                guard let wself = self else { return }
                wself.tootStatusAction.inputs.onNext((wself.secretCredential, wself.postMessage.value, [response.mediaID]))
            }, onError: { [weak self] (error) in
                self?._postResult.onError(error)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - TweetViewModelType

extension TweetViewModel: TweetViewModelOutput {

    var isPostable: Observable<Bool> {
        return postMessage
            .map { !$0.isEmpty }
            .observeOn(MainScheduler.instance)
            .asObservable()
    }

    var user: Observable<User> {
        return postUser.asObservable()
    }

    var postResult: Observable<Void> {
        return _postResult.observeOn(MainScheduler.instance).asObservable()
    }

    var newShareImage: Observable<UIImage> {
        return _newShareImage.observeOn(MainScheduler.instance).asObservable()
    }
}
