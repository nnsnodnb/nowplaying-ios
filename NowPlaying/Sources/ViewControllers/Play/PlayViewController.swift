//
//  PlayViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import RxSwift
import ScrollFlowLabel
import UIKit

final class PlayViewController: UIViewController {
    // MARK: - Dependency
    typealias Dependency = PlayViewModelType

    // MARK: - Properties
    private let viewModel: PlayViewModelType
    private let environment: EnvironmentProtocol
    private let disposeBag = DisposeBag()

    @IBOutlet private var coverImageView: UIImageView! {
        didSet {
            coverImageView.layer.shadowColor = Asset.Colors.shadowMain.color.cgColor
            coverImageView.layer.shadowOffset = .zero
            coverImageView.layer.shadowRadius = 20
            coverImageView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet private var songNameLabel: ScrollFlowLabel! {
        didSet {
            songNameLabel.textColor = .label
            songNameLabel.textAlignment = .center
            songNameLabel.font = .boldSystemFont(ofSize: 20)
            songNameLabel.pauseInterval = 2
            songNameLabel.scrollDirection = .left
            songNameLabel.observeApplicationState()
        }
    }
    @IBOutlet private var artistNameLabel: ScrollFlowLabel! {
        didSet {
            artistNameLabel.textColor = .label
            artistNameLabel.textAlignment = .center
            artistNameLabel.textAlignment = .center
            artistNameLabel.font = .systemFont(ofSize: 16)
            artistNameLabel.pauseInterval = 2
            artistNameLabel.scrollDirection = .left
            artistNameLabel.observeApplicationState()
        }
    }
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var forwardButton: UIButton!
    @IBOutlet private var gearButton: UIButton!
    @IBOutlet private var mastodonButton: UIButton! {
        didSet {
            mastodonButton.imageView?.contentMode = .scaleAspectFit
            mastodonButton.contentHorizontalAlignment = .fill
            mastodonButton.contentVerticalAlignment = .fill
        }
    }
    @IBOutlet private var twitterButton: UIButton! {
        didSet {
            twitterButton.imageView?.contentMode = .scaleAspectFit
            twitterButton.contentHorizontalAlignment = .fill
            twitterButton.contentVerticalAlignment = .fill
        }
    }

    // MARK: - Initialize
    init(dependency: Dependency, environment: EnvironmentProtocol) {
        self.viewModel = dependency
        self.environment = environment
        super.init(nibName: Self.className, bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }
        coverImageView.layer.shadowColor = Asset.Colors.shadowMain.color.cgColor
    }
}

// MARK: - Private method
private extension PlayViewController {
    func bind(to viewModel: PlayViewModelType) {
        // カバー写真
        viewModel.outputs.artworkImage.drive(coverImageView.rx.image).disposed(by: disposeBag)
        viewModel.outputs.artworkScale
            .drive(with: self, onNext: { strongSelf, scale in
                UIView.animate(withDuration: 0.3, delay: 0) { [weak strongSelf] in
                    strongSelf?.coverImageView.transform = .init(scaleX: scale, y: scale)
                }
            })
            .disposed(by: disposeBag)
        // 曲名
        viewModel.outputs.songName.drive(songNameLabel.rx.text).disposed(by: disposeBag)
        // アーティスト名
        viewModel.outputs.artistName.drive(artistNameLabel.rx.text).disposed(by: disposeBag)
        // 戻るボタン
        backButton.rx.tap.asSignal().emit(to: viewModel.inputs.back).disposed(by: disposeBag)
        // 再生ボタン
        playButton.rx.tap.asSignal().emit(to: viewModel.inputs.playPause).disposed(by: disposeBag)
        viewModel.outputs.playPauseImage.drive(playButton.rx.image()).disposed(by: disposeBag)
        // 次へボタン
        forwardButton.rx.tap.asSignal().emit(to: viewModel.inputs.forward).disposed(by: disposeBag)
        // 設定ボタン
        gearButton.rx.tap.asSignal().emit(to: viewModel.inputs.setting).disposed(by: disposeBag)
        // Mastodonボタン
        mastodonButton.rx.tap.asSignal().emit(to: viewModel.inputs.mastodon).disposed(by: disposeBag)
        // Twitterボタン
        twitterButton.rx.tap.asSignal().emit(to: viewModel.inputs.twitter).disposed(by: disposeBag)
    }
}

// MARK: - ViewControllerInjectable
extension PlayViewController: ViewControllerInjectable {}
