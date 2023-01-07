//
//  SettingProviderFooterNoteTableViewCell.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import RxSwift
import UIKit

protocol SettingProviderFooterNoteTableViewCellDelegate: AnyObject {
    func settingProviderFooterNoteTableViewCellDidCopy()
}

final class SettingProviderFooterNoteTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let height: CGFloat = 152

    weak var delegate: SettingProviderFooterNoteTableViewCellDelegate?

    private static let songTitleKey = "__songtitle__"
    private static let artistKey = "__artist__"
    private static let albumKey = "__album__"

    @IBOutlet private var songTitleButton: UIButton! {
        didSet {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.secondaryLabel
            ]
            let attributedString = NSMutableAttributedString(string: Self.songTitleKey, attributes: attributes)
            songTitleButton.setAttributedTitle(attributedString, for: .normal)
        }
    }
    @IBOutlet private var artistButton: UIButton! {
        didSet {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.secondaryLabel
            ]
            let attributedString = NSMutableAttributedString(string: Self.artistKey, attributes: attributes)
            artistButton.setAttributedTitle(attributedString, for: .normal)
        }
    }
    @IBOutlet private var albumButton: UIButton! {
        didSet {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.secondaryLabel
            ]
            let attributedString = NSMutableAttributedString(string: Self.albumKey, attributes: attributes)
            albumButton.setAttributedTitle(attributedString, for: .normal)
        }
    }

    private var disposeBag = DisposeBag()

    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
    }

    func configure() {
        // 曲名ボタン
        songTitleButton.rx.tap.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                UIPasteboard.general.string = Self.songTitleKey
                strongSelf.delegate?.settingProviderFooterNoteTableViewCellDidCopy()
            })
            .disposed(by: disposeBag)
        // アーティスト名ボタン
        artistButton.rx.tap.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                UIPasteboard.general.string = Self.artistKey
                strongSelf.delegate?.settingProviderFooterNoteTableViewCellDidCopy()
            })
            .disposed(by: disposeBag)
        // アルバム名ボタン
        albumButton.rx.tap.asSignal()
            .emit(with: self, onNext: { strongSelf, _ in
                UIPasteboard.general.string = Self.albumKey
                strongSelf.delegate?.settingProviderFooterNoteTableViewCellDidCopy()
            })
            .disposed(by: disposeBag)
    }
}
