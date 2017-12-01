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

class TweetViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var artworkImageButton: UIButton!
    @IBOutlet weak var artworkImageButtonTopMargin: NSLayoutConstraint!
    @IBOutlet weak var artworkImageButtonHeight: NSLayoutConstraint!

    var tweetText: String?
    var shareImage: UIImage?
    var isMastodon = false

    fileprivate var keyboardHeight: CGFloat = 0

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
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

    fileprivate func setupTextView() {
        textView.becomeFirstResponder()
        textView.text = tweetText
    }

    fileprivate func setupArtworkImageButton() {
        if shareImage == nil || tweetText == nil {
            artworkImageButton.isHidden = true
            artworkImageButtonHeight.constant = 0
            return
        }
        artworkImageButton.alpha = 0
        artworkImageButton.imageView?.backgroundColor = UIColor.clear
        artworkImageButton.setImage(shareImage, for: .normal)
    }

    fileprivate func setupNavigationBar() {
        guard navigationController != nil else {
            return
        }
        title = isMastodon ? "トゥート" : "ツイート"
        let cancelButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(onTapCancelButton(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        let tweetButton = UIBarButtonItem(title: isMastodon ? "トゥート" : "ツイート", style: .done, target: self, action: #selector(onTapTweetButton(_:)))
        navigationItem.rightBarButtonItem = tweetButton
    }

    fileprivate func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    fileprivate func resizeTextView() {
        textViewHeight.constant = UIScreen.main.bounds.size.height - keyboardHeight - artworkImageButtonHeight.constant - (artworkImageButtonTopMargin.constant * 2)
        UIView.animate(withDuration: 0.5) { [unowned self] in
            self.artworkImageButton.alpha = 1
        }
    }

    // MARK: - UIBarButtonItem target

    @objc func onTapCancelButton(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @objc func onTapTweetButton(_ sender: UIBarButtonItem) {
        SVProgressHUD.show()
        if shareImage != nil {
            if isMastodon {
                // TODO: - 画像つきトゥート
            } else {
                TwitterClient.shared.client?.sendTweet(withText: textView.text, image: shareImage!, completion: { [unowned self] (tweet, error) in
                    if error != nil {
                        SVProgressHUD.dismiss()
                        self.showError(error: error!)
                        return
                    }
                    SVProgressHUD.dismiss()
                    self.textView.resignFirstResponder()
                    self.dismiss(animated: true, completion: nil)
                })
            }
        } else {
            if isMastodon {
                MastodonClient.shared.toot(text: textView.text, handler: { [unowned self] (error) in
                    if error != nil {
                        SVProgressHUD.dismiss()
                        self.showError(error: error!)
                        return
                    }
                    SVProgressHUD.dismiss()
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                TwitterClient.shared.client?.sendTweet(withText: textView.text, completion: { [unowned self] (tweet, error) in
                    if error != nil {
                        SVProgressHUD.dismiss()
                        self.showError(error: error!)
                        return
                    }
                    SVProgressHUD.dismiss()
                    self.dismiss(animated: true, completion: nil)
                })
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
            })
        })
        sheet.popoverPresentationController?.sourceView = artworkImageButton
        sheet.popoverPresentationController?.sourceRect = artworkImageButton.frame
        present(sheet, animated: true, completion: nil)
    }
}
