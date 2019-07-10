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
            completion?(nil, ImagePipeline.Error.dataLoadingFailed(error))
            return
        }
        var imageRequest = ImageRequest(url: url)
        imageRequest.priority = .high

        _ = ImagePipeline.shared.loadImage(with: imageRequest) { [weak self] (response, error) in
            self?.setImage(response?.image, for: .normal)
            completion?(response, error)
        }
    }
}
