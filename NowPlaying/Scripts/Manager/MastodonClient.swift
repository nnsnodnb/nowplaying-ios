//
//  MastodonClient.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/12/01.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import Alamofire
import KeychainAccess
import SVProgressHUD
import MediaPlayer
import FirebaseAnalytics

class MastodonClient: NSObject {

    static let shared = MastodonClient()

    private let keychain = Keychain(service: keychainServiceKey)
    private let baseUrl = UserDefaults.string(forKey: .mastodonHostname) ?? ""

    func toot(text: String, image: UIImage?, handler: @escaping ((Error?) -> ())) {
        guard let image = image, let imageData = UIImagePNGRepresentation(image) else {
            toot(text: text) {
                handler($0)
            }
            return
        }

        upload(imageData: imageData) { [weak self] (encodingResult) in
            guard let `self` = self else { return }
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON() { (response) in
                    guard let json = response.result.value as? Parameters, let mediaId = json["id"] as? String else { return }
                    let paramter = [
                        "status": text,
                        "media_ids": [mediaId] as AnyObject,
                        "visibility": "public"
                    ] as Parameters
                    self.request(self.baseUrl + "/api/v1/statuses", method: .post, parameter: paramter) { (response) in
                        guard response.result.isSuccess else {
                            handler(response.error)
                            return
                        }
                        handler(nil)
                    }
                }
            case .failure(let encodingError):
                handler(encodingError)
            }
        }
    }

    func toot(text: String, handler: @escaping ((Error?) -> ())) {
        let parameter = ["status": text]
        request(baseUrl + "/api/v1/statuses", method: .post, parameter: parameter) { (response) in
            guard response.result.isSuccess else {
                handler(response.error)
                return
            }
            handler(nil)
        }
    }

    /* 画像アップロード */
    func upload(imageData: Data, handler: @escaping ((SessionManager.MultipartFormDataEncodingResult) -> ())) {
        do {
            let accessToken = try keychain.get(KeychainKey.mastodonAccessToken.rawValue) ?? ""
            let filename = Date().timeIntervalSince1970
            let headers = [
                "Content-Type": "application/json; multipart/form-data;",
                "Authorization": "Bearer \(accessToken)",
            ]

            Alamofire.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData, withName: "file", fileName: "\(filename).png", mimeType: "image/png")
            }, to: baseUrl + "/api/v1/media", method: .post, headers: headers) { (encodingResult) in
                handler(encodingResult)
            }
        } catch {
            let error = NSError(domain: "", code: 401, userInfo: nil) as Error
            handler(SessionManager.MultipartFormDataEncodingResult.failure(error))
        }
    }

    func request(_ url: String, method: HTTPMethod, parameter: Dictionary<String, Any>?, handler: @escaping ((DataResponse<Any>) -> ())) {
        var header: [String: String] = ["Content-Type": "application/json"]
        do {
            let accessToken = try keychain.get(KeychainKey.mastodonAccessToken.rawValue) ?? ""
            header["Authorization"] = "Bearer \(accessToken)"
        } catch {}

        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 15

        manager.request(url, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: header)
            .responseJSON { (response) in
                handler(response)
            }
    }

    func autoToot(_ song: MPMediaItem?, resultCompletion: @escaping ((Bool, Error?) -> Void)) {
        // Mastodonへのオートツイートオフ or Mastodonのログインなしの場合、早期終了
        if !UserDefaults.bool(forKey: .isMastodonAutoToot) || !UserDefaults.bool(forKey: .isMastodonLogin) {
            return
        }

        SVProgressHUD.show()
        let message = "\(song?.title ?? "") by \(song?.artist ?? "") #NowPlaying"
        if let artwork = song?.artwork, UserDefaults.bool(forKey: .isMastodonWithImage),
            let image = artwork.image(at: artwork.bounds.size) {
            Analytics.logEvent("post", parameters: [
                "type": "mastodon",
                "auto_post": true,
                "image": true,
                "artist_name": song?.artist ?? "",
                "song_name": song?.title ?? ""]
            )
            MastodonClient.shared.toot(text: message, image: image) { (error) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    resultCompletion(error == nil, error)
                }
            }
        } else {
            Analytics.logEvent("post", parameters: [
                "type": "tweet",
                "auto_post": true,
                "image": false,
                "artist_name": song?.artist ?? "",
                "song_name": song?.title ?? ""]
            )
            MastodonRequest.Toot(status: message).send { (result) in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    switch result {
                    case .success:
                        resultCompletion(true, nil)
                    case .failure(let error):
                        resultCompletion(false, error.error)
                    }
                }
            }
        }
    }
}
