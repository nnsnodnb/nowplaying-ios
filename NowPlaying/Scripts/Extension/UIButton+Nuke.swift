//
//  UIButton+Nuke.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/07/09.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Nuke
import UIKit

extension UIButton {

    func setImage(with url: URL?, completion: ImageTask.Completion? = nil) {
        guard let url = url else {
            let error = NSError(domain: "moe.nnsnodnb.nowplaying", code: 0, userInfo: ["error": "url is nil."])
            completion?(.failure(ImagePipeline.Error.dataLoadingFailed(error)))
            return
        }
        var imageRequest = ImageRequest(url: url)
        imageRequest.priority = .high

        _ = ImagePipeline.shared.loadImage(with: imageRequest) { [weak self] (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async { self?.setImage(response.image, for: .normal) }
                completion?(.success(response))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
