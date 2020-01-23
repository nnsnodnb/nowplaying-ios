//
//  PlayViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import GoogleMobileAds
import RxCocoa
import RxSwift
import ScrollFlowLabel
import UIKit

final class PlayViewController: UIViewController {

    @IBOutlet private weak var artworkImageView: UIImageView! {
        didSet {
            artworkImageView.layer.shadowOffset = .zero
            artworkImageView.layer.shadowRadius = 20
            artworkImageView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet private weak var songNameLabel: ScrollFlowLabel! {
        didSet {
            if #available(iOS 13.0, *) {
                songNameLabel.textColor = .label
            } else {
                songNameLabel.textColor = .black
            }
            songNameLabel.textAlignment = .center
            songNameLabel.font = .boldSystemFont(ofSize: 21)
            songNameLabel.pauseInterval = 2
            songNameLabel.scrollDirection = .left
            songNameLabel.observeApplicationState()
        }
    }
    @IBOutlet private weak var artistNameLabel: ScrollFlowLabel! {
        didSet {
            if #available(iOS 13.0, *) {
                artistNameLabel.textColor = .label
            } else {
                artistNameLabel.textColor = .black
            }
            artistNameLabel.textAlignment = .center
            artistNameLabel.font = .systemFont(ofSize: 16)
            artistNameLabel.pauseInterval = 2
            artistNameLabel.scrollDirection = .left
            artistNameLabel.observeApplicationState()
        }
    }
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var gearButton: UIButton! {
        didSet {
            gearButton.rx.tap.bind(to: viewModel.input.gearButtonTrigger).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var mastodonButton: UIButton!
    @IBOutlet private weak var twitterButton: UIButton!
    @IBOutlet private weak var bannerView: GADBannerView!
    @IBOutlet private weak var bannerViewHeight: NSLayoutConstraint! {
        didSet {
            bannerView.adUnitID = Environments.firebaseAdmobBannerID
            bannerView.adSize = kGADAdSizeBanner
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }

    private(set) var viewModel: PlayViewModelType!

    private let disposeBag = DisposeBag()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: PlayViewer

extension PlayViewController: PlayViewer {}

extension PlayViewController {

    struct Dependency {
        let viewModel: PlayViewModelType
    }

    func inject(dependency: Dependency) {
        viewModel = dependency.viewModel
    }
}
