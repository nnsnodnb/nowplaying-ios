//
//  ArtworkPreviewViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/06/27.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

final class ArtworkPreviewViewController: UIViewController {

    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var screenshotPreviewImageView: UIImageView!

    private let previewImageView: UIImageView
    private let disposeBag = DisposeBag()
    private let image: UIImage
    private let _parent: TweetViewController

    private var viewModel: ArtworkPreviewViewModelType!

    // MARK: - Initializer

    init(image: UIImage, parent: TweetViewController) {
        previewImageView = UIImageView(image: image)
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.hero.isEnabled = true
        previewImageView.hero.id = "previewImageView"
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
        if UIScreen.main.bounds.size.width == image.size.width && UIScreen.main.bounds.size.height == image.size.height {
            screenshotPreviewImageView.image = image
        } else {
            screenshotPreviewImageView.removeFromSuperview()
            view.addSubview(previewImageView)
            previewImageView.snp.makeConstraints {
                $0.top.equalTo(closeButton.snp.bottom).offset(51)
                $0.left.equalTo(closeButton.snp.left)
                $0.centerX.equalToSuperview()
                let height = (UIScreen.main.bounds.size.width - (16 * 2)) * image.size.height / image.size.width
                $0.height.equalTo(height)
            }
        }

        let inputs = ArtworkPreviewViewModelInput(closeButton: closeButton.rx.tap.asObservable(),
                                                  parent: _parent, currentViewController: self)
        viewModel = ArtworkPreviewViewModel(inputs: inputs)
    }
}
