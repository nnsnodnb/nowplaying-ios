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
    private let disposeBag = DisposeBag()

    @IBOutlet private var coverImageView: UIImageView!
    @IBOutlet private var songNameLabel: ScrollFlowLabel!
    @IBOutlet private var artistNameLabel: ScrollFlowLabel!
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
    init(dependency: Dependency) {
        self.viewModel = dependency
        super.init(nibName: "PlayViewController", bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
    }
}

// MARK: - Private method
private extension PlayViewController {

    func bind(to viewModel: PlayViewModelType) {
        // カバー写真

        // 曲名

        // アーティスト名

        // 戻るボタン

        // 再生ボタン

        // 次へボタン

        // 設定ボタン

        // Mastodonボタン

        // Twitterボタン
    }
}

// MARK: - ViewControllerInjectable
extension PlayViewController: ViewControllerInjectable {}
