//
//  PostFormatHelpView.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/16.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit
import RxSwift
import SVProgressHUD

final class PostFormatHelpView: UIView {

    @IBOutlet private weak var songTitleButton: UIButton! {
        didSet {
            songTitleButton.rx.tap
                .subscribe(onNext: { (_) in
                    self.setPasteboard(withText: "__songtitle__")
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var artistButton: UIButton! {
        didSet {
            artistButton.rx.tap
                .subscribe(onNext: { (_) in
                    self.setPasteboard(withText: "__artist__")
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var albumButton: UIButton! {
        didSet {
            albumButton.rx.tap
                .subscribe(onNext: { (_) in
                    self.setPasteboard(withText: "__album__")
                })
                .disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()

    // MARK: - Private method

    private func setPasteboard(withText text: String) {
        UIPasteboard.general.string = text
        SVProgressHUD.showInfo(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 0.2)
    }
}
