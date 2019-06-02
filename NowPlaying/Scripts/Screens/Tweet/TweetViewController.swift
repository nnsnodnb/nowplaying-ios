//
//  TweetViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import FirebaseAnalytics
import SVProgressHUD
import RxCocoa
import RxKeyboard
import RxSwift
import TwitterKit
import UIKit

final class TweetViewController: UIViewController {

    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.becomeFirstResponder()
            textView.text = postContent.postMessage
        }
    }
    @IBOutlet private weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var artworkImageButton: UIButton! {
        didSet {
            if shareImage == nil {
                artworkImageButton.isHidden = true
                return
            }
            artworkImageButton.alpha = 0
            artworkImageButton.imageView?.backgroundColor = UIColor.clear
            artworkImageButton.setImage(shareImage, for: .normal)
        }
    }
    @IBOutlet private weak var artworkImageButtonTopMargin: NSLayoutConstraint!
    @IBOutlet private weak var artworkImageButtonHeight: NSLayoutConstraint! {
        didSet {
            if shareImage == nil { artworkImageButtonHeight.constant = 0 }
        }
    }

    private let postContent: PostContent
    private let disposeBag = DisposeBag()

    private var keyboardHeight: CGFloat = 0
    private var isMastodon: Bool {
        return postContent.service == .mastodon
    }
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

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] (height) in
                guard let wself = self else { return }
                wself.keyboardHeight = height
                wself.textViewHeight.constant = UIScreen.main.bounds.size.height - height - wself.artworkImageButtonHeight.constant - (wself.artworkImageButtonTopMargin.constant * 2)
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.isHidden.asObservable()
            .take(1)
            .subscribe(onNext: { [weak self] (_) in
                UIView.animate(withDuration: 0.5) {
                    self?.artworkImageButton.alpha = 1
                }
            })
            .disposed(by: disposeBag)

        let inputs = TweetViewModelInput(postContent: postContent,textViewText: textView.rx.text.orEmpty.asObservable())
        viewModel = TweetViewModel(inputs: inputs)

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
                if let shareImage = self?.shareImage {
                    self?.viewModel.preparePost(withImage: shareImage)
                } else {
                    self?.viewModel.preparePost()
                }
            })
            .disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = postButton
    }

    private func resizeTextView() {
        textViewHeight.constant = UIScreen.main.bounds.size.height - keyboardHeight - artworkImageButtonHeight.constant - (artworkImageButtonTopMargin.constant * 2)
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.artworkImageButton.alpha = 1
        }
    }

    // MARK: - IBAction

    @IBAction func onTapArtworkImageButton(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: "アートワークを削除します", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "削除", style: .destructive) { [unowned self] (action) in
            self.shareImage = nil
            UIView.animate(withDuration: 0.3, animations: {
                self.artworkImageButton.alpha = 0.0
            }, completion: { (completion) in
                self.artworkImageButton.setImage(nil, for: .normal)
                self.artworkImageButtonHeight.constant = 0
                self.resizeTextView()
                Analytics.logEvent("delete_image", parameters: ["type": "action"])
            })
        })
        sheet.popoverPresentationController?.sourceView = artworkImageButton
        sheet.popoverPresentationController?.sourceRect = artworkImageButton.frame
        present(sheet, animated: true, completion: nil)
    }
}
