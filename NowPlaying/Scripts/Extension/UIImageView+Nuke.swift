//
//  UIImageView+Nuke.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/07/07.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Nuke
import UIKit

extension UIImageView {

    func setImage(with url: URL?, completion: ImageTask.Completion? = nil) {
        guard let url = url else {
            let error = NSError(domain: "moe.nnsnodnb.nowplaying", code: 0, userInfo: ["error": "url is nil."])
            completion?(.failure(ImagePipeline.Error.dataLoadingFailed(error)))
            return
        }
        var imageRequest = ImageRequest(url: url)
        imageRequest.priority = .high

        loadImage(with: imageRequest, into: self, completion: completion)
    }
}
