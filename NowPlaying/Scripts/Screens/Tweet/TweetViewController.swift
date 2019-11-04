//
//  TweetViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import Feeder
import FirebaseAnalytics
import Hero
import RxCocoa
import RxKeyboard
import RxSwift
import SVProgressHUD
import UIKit

final class TweetViewController: UIViewController {

    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.becomeFirstResponder()
        }
    }
    @IBOutlet private weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var iconImageButton: UIButton! {
        didSet {
            iconImageButton.imageView?.contentMode = .scaleAspectFit
            iconImageButton.contentVerticalAlignment = .fill
            iconImageButton.contentHorizontalAlignment = .fill
        }
    }
    @IBOutlet private weak var artworkImageButton: ShadowButton! {
        didSet {
            artworkImageButton.imageView?.contentMode = .scaleAspectFit
            artworkImageButton.contentVerticalAlignment = .fill
            artworkImageButton.contentHorizontalAlignment = .fill
            artworkImageButton.isHidden = shareImage == nil
            artworkImageButton.setImage(shareImage, for: .normal)
            artworkImageButton.rx.tap
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] (_) in
                    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    sheet.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
                    let previewAction = UIAlertAction(title: "プレビュー", style: .default) { [unowned self] (_) in
                        self.showPreviewer()
                    }
                    sheet.addAction(previewAction)
                    sheet.addAction(UIAlertAction(title: "添付画像を削除", style: .destructive) { [unowned self] (_) in
                        Feeder.Impact(.light).impactOccurred()
                        self.shareImage = nil
                        self.artworkImageButton.isHidden = true
                        self.addImageButton.isHidden = false
                        Analytics.logEvent("delete_image", parameters: ["type": "action"])
                    })
                    sheet.preferredAction = previewAction
                    self.present(sheet, animated: true, completion: nil)
                    Feeder.Impact(.light).impactOccurred()
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var addImageButton: UIButton! {
        didSet {
            addImageButton.isHidden = shareImage != nil
        }
    }

    private let postContent: PostContent
    private let disposeBag = DisposeBag()
    private let initialTextViewBottomConstant: CGFloat = 14

    private lazy var isMastodon: Bool = {
        return postContent.service == .mastodon
    }()
    private var shareImage: UIImage?
    private var viewModel: TweetViewModelType!

    // MARK: - Initializer

    init(postContent: PostContent) {
        self.postContent = postContent
        super.init(nibName: R.nib.tweetViewController.name, bundle: R.nib.tweetViewController.bundle)
        shareImage = postContent.shareImage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()

        textView.text = postContent.postMessage

        RxKeyboard.instance.frame
            .drive(onNext: { [weak self] (frame) in
                guard let wself = self else { return }
                wself.textViewBottomConstraint.constant = wself.initialTextViewBottomConstant + frame.size.height
            })
            .disposed(by: disposeBag)

        viewModel = TweetViewModel(inputs: .init(postContent: postContent))

        subscribeViewModel()
        viewModel.getCurrentAccount()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("投稿画面", screenClass: "TweetViewController")
        Analytics.logEvent("screen_open", parameters: [
            "type": isMastodon ? "mastodon" : "twitter",
            "artist_name": postContent.artistName,
            "song_name": postContent.songTitle]
        )
    }

    func forcusToTextView(delay: TimeInterval = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.textView.becomeFirstResponder()
        }
    }

    // MARK: - Private method

    private func setupNavigationBar() {
        guard navigationController != nil else {
            return
        }
        title = isMastodon ? "トゥート" : "ツイート"
        let cancelButton = UIBarButtonItem(title: "閉じる", style: .plain, target: nil, action: nil)
        cancelButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                guard let wself = self else { return }
                wself.textView.resignFirstResponder()
                Analytics.Tweet.cancelPost(isMastodon: wself.isMastodon)
                wself.dismiss(animated: true, completion: nil)
                Feeder.Impact(.light).impactOccurred()
            })
            .disposed(by: disposeBag)
        navigationItem.leftBarButtonItem = cancelButton

        let postButton = UIBarButtonItem(title: isMastodon ? "トゥート" : "ツイート", style: .done, target: nil, action: nil)
        postButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                self?.textView.resignFirstResponder()
                SVProgressHUD.show()
                Feeder.Impact(.medium).impactOccurred()
                self?.viewModel.preparePost(image: self?.shareImage)
            })
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = postButton
    }

    private func showPreviewer() {
        guard let shareImage = self.shareImage else { return }
        textView.resignFirstResponder()
        let viewController = ArtworkPreviewViewController(image: shareImage, parent: self)
        present(viewController, animated: true, completion: nil)
    }

    private func subscribeUIParts() {
        textView.rx.text
            .compactMap { $0 }
            .map { !$0.isEmpty }
            .observeOn(MainScheduler.instance)
            .bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled)
            .disposed(by: disposeBag)

        iconImageButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let viewModel = AccountManageViewModelImpl(service: self.postContent.service)
                let viewController = AccountManageViewController(viewModel: viewModel, service: self.postContent.service, screenType: .selection)
                _ = viewController.selection
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { (user) in
                        self.iconImageButton.setImage(with: user.iconURL)
                    })
                self.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)

        addImageButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let actionSheet = UIAlertController(title: "画像を追加します", message: "どちらを追加しますか？", preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "アートワーク", style: .default) { [unowned self] (_) in
                    guard let artwork = self.postContent.item?.artwork, let image = artwork.image(at: artwork.bounds.size) else {
                        SVProgressHUD.showError(withStatus: "アートワークが見つかりませんでした")
                        SVProgressHUD.dismiss(withDelay: 1)
                        return
                    }
                    self.shareImage = image
                    self.artworkImageButton.setImage(image, for: .normal)
                    self.artworkImageButton.isHidden = false
                    self.addImageButton.isHidden = true
                })
                actionSheet.addAction(UIAlertAction(title: "再生画面のスクリーンショット", style: .default) { (_) in
                    let rect = UIScreen.main.bounds
                    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
                    defer { UIGraphicsEndImageContext() }
                    let context = UIGraphicsGetCurrentContext()!

                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController?.view.layer.render(in: context)

                    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                        SVProgressHUD.showError(withStatus: "アートワークが見つかりませんでした")
                        SVProgressHUD.dismiss(withDelay: 1)
                        return
                    }
                    self.shareImage = image
                    self.artworkImageButton.setImage(image, for: .normal)
                    self.artworkImageButton.isHidden = false
                    self.addImageButton.isHidden = true
                })
                actionSheet.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
                self.present(actionSheet, animated: true, completion: nil)
                Feeder.Selection().selectionChanged()
            })
            .disposed(by: disposeBag)
    }

    private func subscribeViewModel() {
        viewModel.outputs.postResult
            .subscribe(onNext: { [weak self] in
                SVProgressHUD.dismiss()
                Feeder.Notification(.success).notificationOccurred()
                self?.dismiss(animated: true, completion: nil)
            }, onError: { [weak self] (error) in
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                SVProgressHUD.dismiss()
                Feeder.Notification(.error).notificationOccurred()
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
