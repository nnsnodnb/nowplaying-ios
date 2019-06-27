//
//  ArtworkPreviewViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/06/27.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

struct ArtworkPreviewViewModelInput {

    let closeButton: Observable<Void>
    let parent: TweetViewController
    let currentViewController: UIViewController
}

// MARK: - ArtworkPreviewViewOutput

protocol ArtworkPreviewViewModelOutput {

}

// MARK: - ArtworkPreviewViewModelType

protocol ArtworkPreviewViewModelType {

    var outputs: ArtworkPreviewViewModelOutput { get }

    init(inputs: ArtworkPreviewViewModelInput)
}

final class ArtworkPreviewViewModel: ArtworkPreviewViewModelType {

    var outputs: ArtworkPreviewViewModelOutput { return self }

    private let disposeBag = DisposeBag()

    init(inputs: ArtworkPreviewViewModelInput) {
        inputs.closeButton
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { (_) in
                inputs.parent.forcusToTextView(delay: 0.4)
                inputs.currentViewController.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ArtworkPreviewViewModelOutput

extension ArtworkPreviewViewModel: ArtworkPreviewViewModelOutput {}
