//
//  SettingViewController.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import RxDataSources
import RxSwift
import UIKit
import UniformTypeIdentifiers

final class SettingViewController: UIViewController {
    // MARK: - Dependency
    typealias Dependency = SettingViewModelType

    // MARK: - Life Cycle
    private let viewModel: SettingViewModelType
    private let disposeBag = DisposeBag()

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.register(SettingTableViewCell.self)
            tableView.tableFooterView = .init()
        }
    }

    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        navigationItem.rightBarButtonItem = barButtonItem
        return barButtonItem
    }()
    private lazy var dataSource: DataSource = {
        return .init(
            animationConfiguration: .init(insertAnimation: .top, reloadAnimation: .automatic, deleteAnimation: .bottom),
            decideViewTransition: { _, _, changesets in
                return changesets.contains(where: { !$0.insertedSections.isEmpty }) ? .reload : .animated
            },
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(with: SettingTableViewCell.self, for: indexPath)
                cell.configure(item: item)
                return cell
            },
            titleForHeaderInSection: { dataSource, section in
                return dataSource[section].model.sectionTitle
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
        navigationItem.title = "設定"
        bind(to: viewModel)
    }
}

// MARK: - Private method
private extension SettingViewController {
    func bind(to viewModel: SettingViewModelType) {
        // 閉じるボタン
        rightBarButtonItem.rx.tap.asSignal()
            .emit(to: viewModel.inputs.dismiss)
            .disposed(by: disposeBag)
        // UITableView
        tableView.rx.modelSelected(Item.self).asSignal()
            .emit(to: viewModel.inputs.item)
            .disposed(by: disposeBag)
        tableView.rx.itemSelected.asSignal()
            .emit(with: self, onNext: { strongSelf, indexPath in
                strongSelf.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.outputs.dataSource
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

// MARK: - DataSource
private extension SettingViewController {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>
}

// MARK: - SectionModel
extension SettingViewController {
    typealias SectionModel = AnimatableSectionModel<Section, Item>
}

// MARK: - Section
extension SettingViewController {
    enum Section: String, Equatable, IdentifiableType {
        case sns
        case app

        // MARK: - Properties
        var identity: String {
            return rawValue
        }
        var sectionTitle: String {
            switch self {
            case .sns:
                return "SNS設定"
            case .app:
                return "アプリについて"
            }
        }
    }
}

// MARK: - Item
extension SettingViewController {
    enum Item: Equatable, IdentifiableType {
        case socialType(SocialType)
        case link(Link)
        case removeAdMob
        case review

        // MARK: - Properties
        var identity: String {
            switch self {
            case let .socialType(socialType):
                return socialType.rawValue
            case let .link(link):
                return link.rawValue
            case .removeAdMob:
                return "removeAdMob"
            case .review:
                return "review"
            }
        }
        var title: String {
            switch self {
            case let .socialType(socialType):
                switch socialType {
                case .twitter:
                    return "Twitter設定"
                case .mastodon:
                    return "Mastodon設定"
                }
            case let .link(link):
                return link.title
            case .removeAdMob:
                return "アプリ内広告削除(有料)"
            case .review:
                return "レビューする"
            }
        }
    }
}

// MARK: - Link
extension SettingViewController {
    enum Link: String, Equatable {
        case developer
        case github
        case contact

        // MARK: - Properties
        var url: URL {
            switch self {
            case .developer:
                return URL(string: "https://twitter.com/nnsnodnb")!
            case .github:
                return URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!
            case .contact:
                return URL(string: "https://forms.gle/gE5ms3bEM5A85kdVA")!
            }
        }
        var title: String {
            switch self {
            case .developer:
                return "開発者(Twitter)"
            case .github:
                return "ソースコード(GitHub)"
            case .contact:
                return "機能要望・バグ報告"
            }
        }
    }
}

// MARK: - ViewControllerInjectable
extension SettingViewController: ViewControllerInjectable {}
