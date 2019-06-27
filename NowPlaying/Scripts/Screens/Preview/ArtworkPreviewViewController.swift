//
//  ArtworkPreviewViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2019/06/27.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit

final class ArtworkPreviewViewController: UIViewController {

    @IBOutlet private weak var previewImageView: UIImageView!

    private let image: UIImage

    // MARK: - Initializer

    init(image: UIImage) {
        self.image = image
        super.init(nibName: R.nib.artworkPreviewViewController.name, bundle: R.nib.artworkPreviewViewController.bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        previewImageView.image = image
    }
}
