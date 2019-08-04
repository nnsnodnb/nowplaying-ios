//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Oka Yuya on 2018/04/11.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import NotificationCenter
import RxCocoa
import RxSwift
import ScrollFlowLabel
import UIKit

final class TodayViewController: UIViewController {

    @IBOutlet private weak var commonView: UIView!
    @IBOutlet private weak var artworkImageButton: UIButton! {
        didSet {
            artworkImageButton.imageView?.contentMode = .scaleAspectFit
            artworkImageButton.contentHorizontalAlignment = .fill
            artworkImageButton.contentVerticalAlignment = .fill
            artworkImageButton.rx.tap
                .subscribe(onNext: { [unowned self] (_) in
                    let url = URL(string: "nowplaying-ios-nnsnodnb://")!
                    self.extensionContext?.open(url, completionHandler: nil)
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var songNameScrollLabel: ScrollFlowLabel! {
        didSet {
            songNameScrollLabel.textColor = .black
            songNameScrollLabel.textAlignment = .left
            songNameScrollLabel.font = .boldSystemFont(ofSize: 20)
            songNameScrollLabel.pauseInterval = 2
            songNameScrollLabel.scrollDirection = .left
            songNameScrollLabel.observeApplicationState()
        }
    }
    @IBOutlet private weak var artistNameScrollLabel: ScrollFlowLabel! {
        didSet {
            artistNameScrollLabel.textColor = .black
            artistNameScrollLabel.textAlignment = .left
            artistNameScrollLabel.font = .systemFont(ofSize: 17)
            artistNameScrollLabel.pauseInterval = 2
            artistNameScrollLabel.scrollDirection = .left
            artistNameScrollLabel.observeApplicationState()
        }
    }
    @IBOutlet private weak var deniedView: UIView!

    private let disposeBag = DisposeBag()
    private let viewModel: TodayViewModelType = TodayViewModel()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.outputs.nowPlayingItem
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (item) in
                guard let wself = self else { return }
                let image = item.artwork?.image(at: wself.artworkImageButton.frame.size)
                wself.artworkImageButton.setImage(image, for: .normal)
                wself.songNameScrollLabel.text = item.title
                wself.artistNameScrollLabel.text = item.artist
            })
            .disposed(by: disposeBag)

        viewModel.outputs.viewType
            .map { $0 == .common }
            .subscribe(onNext: { [weak self] (isCommon) in
                self?.commonView.isHidden = !isCommon
                self?.deniedView.isHidden = isCommon
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.inputs.accessMusicLibraryTrigger.accept(())
    }
}

// MARK: - NCWidgetProviding

extension TodayViewController: NCWidgetProviding {

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(.newData)
    }
}
