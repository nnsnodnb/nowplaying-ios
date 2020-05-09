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
            artworkImageView.layer.shadowColor = R.color.artworkShadowColor()!.cgColor
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
    @IBOutlet private weak var playButton: UIButton! {
        didSet {
            playButton.rx.tap.bind(to: viewModel.inputs.playPauseButtonTrigger).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var previousButton: UIButton! {
        didSet {
            previousButton.rx.tap.bind(to: viewModel.inputs.previousButtonTrigger).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var nextButton: UIButton! {
        didSet {
            nextButton.rx.tap.bind(to: viewModel.inputs.nextButtonTrigger).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var gearButton: UIButton! {
        didSet {
            gearButton.rx.tap.bind(to: viewModel.inputs.gearButtonTrigger).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var mastodonButton: UIButton! {
        didSet {
            mastodonButton.rx.tap.bind(to: viewModel.inputs.mastodonButtonTrigger).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var twitterButton: UIButton! {
        didSet {
            twitterButton.rx.tap.bind(to: viewModel.inputs.twitterButtonTrigger).disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var bannerView: GADBannerView! {
        didSet {
            bannerView.adUnitID = Environments.firebaseAdmobBannerID
            bannerView.adSize = kGADAdSizeBanner
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }
    @IBOutlet private weak var bannerViewHeight: NSLayoutConstraint!

    private(set) var viewModel: PlayViewModelType!

    private let disposeBag = DisposeBag()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.outputs.artworkImage
            .drive(onNext: { [weak self] in
                self?.artworkImageView.image = $0
            })
            .disposed(by: disposeBag)

        viewModel.outputs.artworkScale
            .drive(onNext: { [weak self] in
                let transform: CGAffineTransform = $0 == 1 ? .identity : .init(scaleX: $0, y: $0)
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.artworkImageView.transform = transform
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.songName
            .drive(onNext: { [weak self] in
                self?.songNameLabel.text = $0
            })
            .disposed(by: disposeBag)

        viewModel.outputs.artistName
            .drive(onNext: { [weak self] in
                self?.artistNameLabel.text = $0
            })
            .disposed(by: disposeBag)

        viewModel.outputs.playButtonImage
            .drive(onNext: { [weak self] in
                self?.playButton.setImage($0, for: .normal)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.takeScreenshot
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .map {
                UIGraphicsImageRenderer(bounds: UIScreen.main.bounds).image { [weak self] in
                    self?.view.layer.render(in: $0.cgContext)
                }
            }
            .bind(to: viewModel.inputs.tookScreenshot)
            .disposed(by: disposeBag)

        viewModel.outputs.hideAdMob.bind(to: bannerView.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.hideAdMob.map { _ in 0 }.bind(to: bannerViewHeight.rx.constant).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.countUpTrigger.accept(())
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *), previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            artworkImageView.layer.shadowColor = R.color.artworkShadowColor()!.cgColor
        }
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
