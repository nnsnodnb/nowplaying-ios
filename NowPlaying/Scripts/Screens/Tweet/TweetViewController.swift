//
//  TweetViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import FirebaseAnalytics
import SVProgressHUD
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

        RxKeyboard.instance.isHidden
            .drive(onNext: { [weak self] (_) in
                UIView.animate(withDuration: 0.5) {
                    self?.artworkImageButton.alpha = 1
                }
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
        let cancelButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(onTapCancelButton(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        let tweetButton = UIBarButtonItem(title: isMastodon ? "トゥート" : "ツイート", style: .done, target: self, action: #selector(onTapTweetButton(_:)))
        navigationItem.rightBarButtonItem = tweetButton
    }

    private func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func resizeTextView() {
        textViewHeight.constant = UIScreen.main.bounds.size.height - keyboardHeight - artworkImageButtonHeight.constant - (artworkImageButtonTopMargin.constant * 2)
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.artworkImageButton.alpha = 1
        }
    }

    private func treatmentRespones(_ error: Error?) {
        if error != nil {
            SVProgressHUD.dismiss()
            showError(error: error!)
            return
        }
        SVProgressHUD.dismiss()
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UIBarButtonItem target

    @objc func onTapCancelButton(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        Analytics.logEvent("tap", parameters: [
            "type": isMastodon ? "mastodon" : "twitter",
            "button": "post_close"]
        )
        dismiss(animated: true, completion: nil)
    }

    @objc func onTapTweetButton(_ sender: UIBarButtonItem) {
        SVProgressHUD.show()
        if let image = shareImage {
            if isMastodon {
                Analytics.logEvent("post", parameters: [
                    "type": "mastodon",
                    "auto_post": false,
                    "image": image,
                    "artist_name": postContent.artistName,
                    "song_name": postContent.songTitle]
                )
                MastodonClient.shared.toot(text: textView.text, image: image) { [weak self] (error) in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        guard let wself = self else { return }
                        if error == nil {
                            wself.textView.resignFirstResponder()
                            wself.dismiss(animated: true, completion: nil)
                            return
                        }
                        wself.showError(error: error!)
                    }
                }
            } else {
                Analytics.logEvent("post", parameters: [
                    "type": "twitter",
                    "auto_post": false,
                    "image": image,
                    "artist_name": postContent.artistName,
                    "song_name": postContent.songTitle]
                )
                TwitterClient.shared.client?.sendTweet(withText: textView.text, image: image) { [weak self] (tweet, error) in
                    guard let `self` = self else { return }
                    self.treatmentRespones(error)
                }
            }
        } else {
            if isMastodon {
                Analytics.logEvent("post", parameters: [
                    "type": "mastodon",
                    "auto_post": false,
                    "image": false,
                    "artist_name": postContent.artistName,
                    "song_name": postContent.songTitle]
                )
                MastodonRequest.Toot(status: textView.text).send { [weak self] (result) in
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        guard let `self` = self else { return }
                        switch result {
                        case .success:
                            self.textView.resignFirstResponder()
                            self.dismiss(animated: true, completion: nil)
                        case .failure(let error):
                            self.showError(error: error.error)
                        }
                    }
                }
            } else {
                Analytics.logEvent("post", parameters: [
                    "type": "twitter",
                    "auto_post": false,
                    "image": false,
                    "artist_name": postContent.artistName,
                    "song_name": postContent.songTitle]
                )
                TwitterClient.shared.client?.sendTweet(withText: textView.text, completion: { [unowned self] (tweet, error) in
                    self.treatmentRespones(error)
                })
            }
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
