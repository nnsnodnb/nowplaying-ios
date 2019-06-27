//
//  ArtworkPreviewViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/06/27.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit
import RxSwift

final class ArtworkPreviewViewController: UIViewController {

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var previewImageView: UIImageView! {
        didSet {
            previewImageView.image = image
        }
    }

    private let disposeBag = DisposeBag()
    private let image: UIImage
    private let _parent: TweetViewController

    private var viewModel: ArtworkPreviewViewModelType!

    // MARK: - Initializer

    init(image: UIImage, parent: TweetViewController) {
        self.image = image
        self._parent = parent
        super.init(nibName: R.nib.artworkPreviewViewController.name, bundle: R.nib.artworkPreviewViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        let inputs = ArtworkPreviewViewModelInput(closeButton: closeButton.rx.tap.asObservable(),
                                                  parent: _parent, currentViewController: self)
        viewModel = ArtworkPreviewViewModel(inputs: inputs)
    }
}
