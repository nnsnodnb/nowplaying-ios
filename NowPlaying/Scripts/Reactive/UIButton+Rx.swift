//
//  UIButton+Rx.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/05.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Nuke
import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIButton {

    var url: Binder<URL> {
        return .init(base) { (button, url) in
            ImagePipeline.shared.loadImage(with: url, queue: nil, progress: nil, completion: { result in
                if case let .success(response) = result {
                    button.setImage(response.image, for: .normal)
                }
            })
        }
    }
}
