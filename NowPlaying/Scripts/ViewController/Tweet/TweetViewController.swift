//
//  TweetViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/09/21.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import TwitterKit

class TweetViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    var tweetText: String?
    var shareImage: UIImage?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Twitter.sharedInstance().sessionStore.session()?.userID != nil {
            return
        }
        AuthManager.shared.login()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    fileprivate func setup() {
        setupTextView()
        setupNavigationBar()
    }

    fileprivate func setupTextView() {
        textView.becomeFirstResponder()
        textView.text = tweetText
    }

    fileprivate func setupNavigationBar() {
        guard navigationController != nil else {
            return
        }
        title = "ツイート"
        let cancelButton = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(onTapCancelButton(_:)))
        navigationItem.leftBarButtonItem = cancelButton
        let tweetButton = UIBarButtonItem(title: "ツイート", style: .done, target: self, action: #selector(onTapTweetButton(_:)))
        navigationItem.rightBarButtonItem = tweetButton
    }

    fileprivate func showError(error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - UIBarButtonItem target

    func onTapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    func onTapTweetButton(_ sender: UIBarButtonItem) {
        if shareImage != nil {
            TwitterClient.shared.client?.sendTweet(withText: textView.text, image: shareImage!, completion: { [unowned self] (tweet, error) in
                if error != nil {
                    self.showError(error: error!)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            TwitterClient.shared.client?.sendTweet(withText: textView.text, completion: { [unowned self] (tweet, error) in
                if error != nil {
                    self.showError(error: error!)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
}
