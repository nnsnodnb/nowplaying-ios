//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import NotificationCenter
import RxCocoa
import RxSwift
import ScrollFlowLabel
import UIKit

enum ViewType {
    case common
    case denied
}

final class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet private weak var commonView: UIView!
    @IBOutlet private weak var artworkImageButton: UIButton! {
        didSet {
            artworkImageButton.imageView?.contentMode = .scaleAspectFit
            artworkImageButton.contentHorizontalAlignment = .fill
            artworkImageButton.contentVerticalAlignment = .fill
            artworkImageButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    let url = URL(string: "nowplaying-ios-nnsnodnb")!
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

    private lazy var viewModel: TodayViewModelType = TodayViewModel()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.outputs.artworkImage.bind(to: artworkImageButton.rx.image()).disposed(by: disposeBag)
        viewModel.outputs.songName.bind(to: songNameScrollLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.artistName.bind(to: artistNameScrollLabel.rx.text).disposed(by: disposeBag)
        viewModel.outputs.viewType
            .map { $0 != .common }
            .observeOn(MainScheduler.instance)
            .bind(to: commonView.rx.isHidden, deniedView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.fetchNowPlayingItem.accept(())
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
}
