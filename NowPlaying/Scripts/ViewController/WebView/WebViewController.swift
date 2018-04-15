//
//  WebViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/12/01.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import KeychainAccess
import SVProgressHUD
import FirebaseAnalytics

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    var url: URL!
    var handler: ((String?, Error?) -> ())!

    private let keychain = Keychain(service: keychainServiceKey)

    private var gotToken = false

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavibar()
        webView.delegate = self
        webView.loadRequest(URLRequest(url: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private method

    private func setupNavibar() {
        guard navigationController != nil else {
            return
        }
        title = "ログイン"
        let leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onTapLeftBarButtonItem(_:)))
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    private func getToken(_ authorizationCode: String) {
        SVProgressHUD.show()
        do {
            let clientID = try keychain.get(KeychainKey.mastodonClientID.rawValue) ?? ""
            let clientSecret = try keychain.get(KeychainKey.mastodonClientSecret.rawValue) ?? ""

            let parameter: [String: String] = ["grant_type": "authorization_code",
                                               "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
                                               "client_id": clientID,
                                               "client_secret": clientSecret,
                                               "code": authorizationCode]
            MastodonClient.shared.request(UserDefaults.string(forKey: .mastodonHostname)! + "/oauth/token", method: .post, parameter: parameter) { [unowned self] (response) in
                guard response.result.isSuccess, let value = response.result.value as? [String: Any] else {
                    self.handler(nil, response.result.error)
                    SVProgressHUD.dismiss()
                    return
                }
                if let accessToken: String = value["access_token"] as? String {
                    self.keychain[KeychainKey.mastodonAccessToken.rawValue] = accessToken
                    self.handler(accessToken, nil)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } catch {}
    }

    // MARK: - UIBarButtonItem targer

    @objc func onTapLeftBarButtonItem(_ sender: UIBarButtonItem) {
        Analytics.logEvent("tap", parameters: [
            "type": "action",
            "button": "mastodon_login_close"]
        )
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIWebViewDelegate

extension WebViewController : UIWebViewDelegate {

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let path = request.url?.path {
            if !path.hasPrefix("/oauth/authorize/") {
                return true
            }
            let authorizationCode = path.components(separatedBy: "/oauth/authorize/").last!
            UserDefaults.set(authorizationCode, forKey: .mastodonAuthorizationCode)
            gotToken = true
            getToken(authorizationCode)
            return false
        }
        return true
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        if gotToken {
            return
        }
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let alert = UIAlertController(title: nil, message: "読み込みに失敗しました", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ログインをキャンセル", style: .cancel, handler: { [unowned self] (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "再試行", style: .default, handler: { [unowned self] (_) in
            self.webView.reload()
        }))
        present(alert, animated: true, completion: nil)
    }
}
