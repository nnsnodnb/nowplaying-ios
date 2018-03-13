//
//  TweetViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import TwitterKit
import SVProgressHUD
import FirebaseAnalytics

class TweetViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var artworkImageButton: UIButton!
    @IBOutlet weak var artworkImageButtonTopMargin: NSLayoutConstraint!
    @IBOutlet weak var artworkImageButtonHeight: NSLayoutConstraint!

    var tweetText: String?
    var shareImage: UIImage?
    var artistName: String!
    var songName: String!
    var isMastodon = false

    fileprivate var keyboardHeight: CGFloat = 0

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = tweetText
        setupArtworkImageButton()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showKeyboard(_:)),
            name: NSNotification.Name.UIKeyboardDidShow,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
        Analytics.setScreenName("投稿画面", screenClass: "TweetViewController")
        Analytics.logEvent("screen_open", parameters: [
            "type": isMastodon ? "mastodon" : "twitter",
            "artist_name": artistName,
            "song_name": songName]
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIKeyboardDidShow,
            object: nil
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    private func setupArtworkImageButton() {
        if shareImage == nil || tweetText == nil {
            artworkImageButton.isHidden = true
            artworkImageButtonHeight.constant = 0
            return
        }
        artworkImageButton.alpha = 0
        artworkImageButton.imageView?.backgroundColor = UIColor.clear
        artworkImageButton.setImage(shareImage, for: .normal)
    }

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
            Analytics.logEvent("error", parameters: ["post_error": error?.localizedDescription ?? NSNull()])
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
        textView.resignFirstResponder()
        if let image = shareImage {
            if isMastodon {
                Analytics.logEvent("post", parameters: [
                    "type": "mastodon",
                    "auto_post": false,
                    "image": image,
                    "artist_name": artistName,
                    "song_name": songName]
                )
                MastodonClient.shared.toot(text: textView.text, image: image, handler: { [unowned self] (error) in
                    self.treatmentRespones(error)
                })
            } else {
                Analytics.logEvent("post", parameters: [
                    "type": "twitter",
                    "auto_post": false,
                    "image": image,
                    "artist_name": artistName,
                    "song_name": songName]
                )
                TwitterClient.client.sendTweet(withText: textView.text, image: image, completion: { [unowned self] (tweet, error) in
                    self.treatmentRespones(error)
                })
            }
        } else {
            if isMastodon {
                Analytics.logEvent("post", parameters: [
                    "type": "mastodon",
                    "auto_post": false,
                    "image": false,
                    "artist_name": artistName,
                    "song_name": songName]
                )
                MastodonClient.shared.toot(text: textView.text, handler: { [unowned self] (error) in
                    self.treatmentRespones(error)
                })
            } else {
                Analytics.logEvent("post", parameters: [
                    "type": "twitter",
                    "auto_post": false,
                    "image": false,
                    "artist_name": artistName,
                    "song_name": songName]
                )
                TwitterClient.shared.tweet(text: textView.text) { [unowned self] (error) in
                    self.treatmentRespones(error)
                }
            }
        }
    }

    // MARK: - Notification target

    @objc func showKeyboard(_ notification: Notification) {
        if let userInfo = notification.userInfo, let keyboard = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboard.cgRectValue.size.height
            resizeTextView()
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
