//
//  PostFormatHelpView.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/04/19.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import RxCocoa
import RxSwift
import SVProgressHUD
import UIKit

final class PostFormatHelpView: UIView {

    @IBOutlet private weak var songTitleButton: UIButton! {
        didSet {
            songTitleButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.setPasteboard(text: "__songtitle__")
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var artistButton: UIButton! {
        didSet {
            artistButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.setPasteboard(text: "__artist__")
                })
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var albumButton: UIButton! {
        didSet {
            albumButton.rx.tap
                .subscribe(onNext: { [unowned self] in
                    self.setPasteboard(text: "__album__")
                })
                .disposed(by: disposeBag)
        }
    }

    private let disposeBag = DisposeBag()

    private func setPasteboard(text: String) {
        UIPasteboard.general.string = text
        SVProgressHUD.showInfo(withStatus: "コピーしました")
        SVProgressHUD.dismiss(withDelay: 0.5)
    }
}
