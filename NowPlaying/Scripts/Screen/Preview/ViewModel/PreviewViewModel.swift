//
//  PreviewViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/09.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

protocol PreviewViewModelInput {

    var closeButton: PublishRelay<Void> { get }
}

protocol PreviewViewModelOutput {

    var previewImage: Observable<UIImage> { get }
}

protocol PreviewViewModelType: AnyObject {

    var inputs: PreviewViewModelInput { get }
    var outputs: PreviewViewModelOutput { get }
    init(router: PreviewRoutable, image: UIImage)
}

final class PreviewViewModel: PreviewViewModelType {

    var inputs: PreviewViewModelInput { return self }
    var outputs: PreviewViewModelOutput { return self }

    let closeButton: PublishRelay<Void> = .init()
    let previewImage: Observable<UIImage>

    private let disposeBag = DisposeBag()

    init(router: PreviewRoutable, image: UIImage) {
        previewImage = .just(image, scheduler: MainScheduler.instance)

        closeButton
            .subscribe(onNext: {
                router.dismiss()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PreviewViewModelInput

extension PreviewViewModel: PreviewViewModelInput {}

// MARK: - PreviewViewModelOutput

extension PreviewViewModel: PreviewViewModelOutput {}
