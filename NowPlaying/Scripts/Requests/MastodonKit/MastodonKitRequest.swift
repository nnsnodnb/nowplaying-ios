//
//  MastodonKitRequest.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/17.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import MastodonKit
import UIKit

struct MastodonKitRequest {

    private let client: Client

    init(secret: SecretCredential) {
        client = .init(baseURL: "https://\(secret.domainName)", accessToken: secret.authToken)
    }

    func postToot(status: String, media: Data? = nil, completion: @escaping (Result<Status>) -> Void) {
        if let media = media, let data = compressionMedia(media) {
            client.run(Media.upload(data: data)) { (result) in
                switch result {
                case .success(let attachment, _):
                    let request = Statuses.create(status: status, mediaIDs: [attachment.id], visibility: .private)
                    self.client.run(request, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            client.run(Statuses.create(status: status, visibility: .private), completion: completion)
        }
    }

    // MARK: - Private method

    private func compressionMedia(_ media: Data) -> Data? {
        if Double(media.count) < 5e6 { return media } // 5MB以上であれば圧縮する
        return UIImage(data: media)?.jpegData(compressionQuality: 0.3)
    }
}
