//
//  SettingProviderViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2023/01/07.
//

import Differentiator
import KRProgressHUD
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class SettingProviderViewController: UIViewController {
    // MARK: - Dependency
    typealias Dependency = SettingProviderViewModelType

    // MARK: - Properties
    private let viewModel: SettingProviderViewModelType
    private let environment: EnvironmentProtocol
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
}

// MARK: - Private method
private extension SettingProviderViewController {
    func bind(to viewModel: SettingProviderViewModelType) {
        // タイトル
        navigationItem.title = viewModel.outputs.title
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
extension SettingProviderViewController: UITableViewDelegate {
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
extension SettingProviderViewController: SettingProviderFooterNoteTableViewCellDelegate {
    func settingProviderFooterNoteTableViewCellDidCopy() {
        KRProgressHUD.showInfo(withMessage: "コピーしました")
    }
}

// MARK: - DataSource
private extension SettingProviderViewController {
    typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel>
}

// MARK: - SectionModel
extension SettingProviderViewController {
    typealias SectionModel = Differentiator.SectionModel<Section, Item>
}

// MARK: - Section
extension SettingProviderViewController {
    enum Section: Equatable {
        case socialType(SocialType)
        case format
        case footer

        // MARK: - Properties
        var title: String? {
            switch self {
            case let .socialType(socialType):
                return socialType.title
            case .format:
                return "自動フォーマット"
            case .footer:
                return nil
            }
        }
    }
}

// MARK: - Item
extension SettingProviderViewController {
    enum Item: Equatable, SettingTableViewCellItemType {
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
extension SettingProviderViewController.Item {
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
extension SettingProviderViewController.Item {
    enum Toggle: Equatable {
        case attachImage
        case auto(SocialType)

        // MARK: - Properties
        var title: String {
            switch self {
            case .attachImage:
                return "画像を添付"
            case let .auto(socialType):
                switch socialType {
                case .twitter:
                    return "自動ツイート"
                case .mastodon:
                    return "自動トゥート"
                }
            }
        }
    }
}

// MARK: - Item.Selection
extension SettingProviderViewController.Item {
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
extension SettingProviderViewController.Item {
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
extension SettingProviderViewController: ViewControllerInjectable {}
