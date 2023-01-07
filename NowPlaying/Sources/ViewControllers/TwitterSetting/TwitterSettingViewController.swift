//
//  TwitterSettingViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2022/05/04.
//

import Differentiator
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class TwitterSettingViewController: UIViewController {
    // MARK: - Dependency
    typealias Dependency = TwitterSettingViewModelType

    // MARK: - Properties
    private let viewModel: TwitterSettingViewModelType
    private let disposeBag = DisposeBag()

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.register(SettingTableViewCell.self)
            tableView.register(SettingToggleTableViewCell.self)
            tableView.register(SettingSelectionTableViewCell.self)
            tableView.register(SettingTextViewTableViewCell.self)
            tableView.register(SettingButtonTableViewCell.self)
            tableView.register(SettingProviderFooterNoteTableViewCell.self)
            tableView.delegate = self
            tableView.tableFooterView = .init()
        }
    }

    private lazy var dataSource: DataSource = {
        return .init(
            configureCell: { [weak self] _, tableView, indexPath, item in
                switch item {
                case let .detail(detail):
                    let cell = tableView.dequeueReusableCell(with: SettingTableViewCell.self, for: indexPath)
                    cell.configure(item: item)
                    return cell
                case let .toggle(toggle):
                    let cell = tableView.dequeueReusableCell(with: SettingToggleTableViewCell.self, for: indexPath)
                    cell.configure(item: item)
                    return cell
                case let .selection(selection):
                    let cell = tableView.dequeueReusableCell(with: SettingSelectionTableViewCell.self, for: indexPath)
                    cell.configure(selection: selection)
                    return cell
                case .textView:
                    let cell = tableView.dequeueReusableCell(with: SettingTextViewTableViewCell.self, for: indexPath)
                    // TODO: バインド
                    return cell
                case let .button(button):
                    let cell = tableView.dequeueReusableCell(with: SettingButtonTableViewCell.self, for: indexPath)
                    cell.configure(button: button)
                    return cell
                case .footerNote:
                    let cell = tableView.dequeueReusableCell(with: SettingProviderFooterNoteTableViewCell.self, for: indexPath)
                    cell.configure()
                    cell.delegate = self
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, section in
                return dataSource[section].model.title
            }
        )
    }()

    // MARK: - Initialize
    init(dependency: Dependency) {
        self.viewModel = dependency
        super.init(nibName: Self.className, bundle: .main)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Twitter設定"
        bind(to: viewModel)
    }
}

// MARK: - Private method
private extension TwitterSettingViewController {
    func bind(to viewModel: TwitterSettingViewModelType) {
        // UITableView
        tableView.rx.itemSelected.asSignal()
            .emit(with: self, onNext: { strongSelf, indexPath in
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        Driver.just(viewModel.outputs.dataSource)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension TwitterSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch dataSource[indexPath] {
        case .detail, .toggle, .selection, .button:
            return 44
        case .textView:
            return 132
        case .footerNote:
            return SettingProviderFooterNoteTableViewCell.height
        }
    }
}

// MARK: - SettingProviderFooterNoteTableViewCellDelegate
extension TwitterSettingViewController: SettingProviderFooterNoteTableViewCellDelegate {
    func settingProviderFooterNoteTableViewCellDidCopy() {
        // TODO: 「コピーしました」表示
    }
}

// MARK: - DataSource
private extension TwitterSettingViewController {
    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel>
}

// MARK: - SectionModel
extension TwitterSettingViewController {
    typealias SectionModel = Differentiator.SectionModel<Section, Item>
}

// MARK: - Section
extension TwitterSettingViewController {
    enum Section: String {
        case twitter
        case format
        case footer

        // MARK: - Properties
        var title: String? {
            switch self {
            case .twitter:
                return "Twitter"
            case .format:
                return "自動フォーマット"
            case .footer:
                return nil
            }
        }
    }
}

// MARK: - Item
extension TwitterSettingViewController {
    enum Item: Equatable, SettingTableViewCellItemType, SettingToggleTableViewCellItemType {
        case detail(Detail)
        case toggle(Toggle)
        case selection(Selection)
        case textView
        case button(Button)
        case footerNote

        // MARK: - Properties
        var title: String {
            switch self {
            case let .detail(detail):
                return detail.title
            case let .toggle(toggle):
                return toggle.title
            case let .selection(selection):
                return selection.title
            case .textView:
                return "textView"
            case let .button(button):
                return button.title
            case .footerNote:
                return "footerNote"
            }
        }
        var image: UIImage? {
            return nil
        }
    }
}

// MARK: - Item.Detail
extension TwitterSettingViewController.Item {
    enum Detail: String {
        case accounts

        // MARK: - Properties
        var title: String {
            switch self {
            case .accounts:
                return "アカウント管理"
            }
        }
    }
}

// MARK: - Item.Toggle
extension TwitterSettingViewController.Item {
    enum Toggle: String {
        case attachImage
        case auto

        // MARK: - Properties
        var title: String {
            switch self {
            case .attachImage:
                return "画像を添付"
            case .auto:
                return "自動ツイート"
            }
        }
    }
}

// MARK: - Item.Selection
extension TwitterSettingViewController.Item {
    enum Selection: String {
        case attachmentType

        // MARK: - Properties
        var title: String {
            switch self {
            case .attachmentType:
                return "投稿時の画像"
            }
        }
    }
}

// MARK: - Item.Button
extension TwitterSettingViewController.Item {
    enum Button: String {
        case reset

        // MARK: - Properties
        var title: String {
            switch self {
            case .reset:
                return "リセット"
            }
        }
    }
}

// MARK: - ViewControllerInjectable
extension TwitterSettingViewController: ViewControllerInjectable {}
