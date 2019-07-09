//
//  TweetViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

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
            if shareImage == nil {
                artworkImageButton.isHidden = true
                return
            }
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
                        self.shareImage = nil
                        self.artworkImageButton.isHidden = true
                        self.addImageButton.isHidden = false
                        Analytics.logEvent("delete_image", parameters: ["type": "action"])
                    })
                    sheet.preferredAction = previewAction
                    self.present(sheet, animated: true, completion: nil)
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

        let inputs = TweetViewModelInput(iconImageButton: iconImageButton.rx.tap.asObservable(),
                                         addImageButton: addImageButton.rx.tap.asObservable(),
                                         postContent: postContent,
                                         textViewText: textView.rx.text.orEmpty.asObservable())
        viewModel = TweetViewModel(inputs: inputs)

        viewModel.outputs.isPostable
            .bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.user
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (user) in
                self.iconImageButton.setImage(with: user.iconURL)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.successRequest
            .subscribe(onNext: { [weak self] (_) in
                SVProgressHUD.dismiss()
                self?.textView.resignFirstResponder()
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.failureRequest
            .subscribe(onNext: { [weak self] (error) in
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        viewModel.getDefaultAccount()
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
            })
            .disposed(by: disposeBag)
        navigationItem.leftBarButtonItem = cancelButton

        let postButton = UIBarButtonItem(title: isMastodon ? "トゥート" : "ツイート", style: .done, target: nil, action: nil)
        postButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                self?.textView.resignFirstResponder()
                SVProgressHUD.show()
                if let shareImage = self?.shareImage {
                    self?.viewModel.preparePost(withImage: shareImage)
                } else {
                    self?.viewModel.preparePost()
                }
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
}
