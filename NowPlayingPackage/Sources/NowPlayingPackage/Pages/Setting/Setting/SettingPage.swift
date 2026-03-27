//
//  SettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import BetterSafariView
import ComposableArchitecture
import SwiftUI

@Reducer
public struct SettingFeature: Sendable {
  // MARK: - Path
  @Reducer
  public enum Path {
    case twitterSetting(SocialServiceSettingFeature)
    case twitterAccountManage(TwitterAccountManageFeature)
    case blueskySetting(SocialServiceSettingFeature)
    case blueskyAccountManage(BlueskyAccountManageFeature)
    case paidContent(PaidContentFeature)
    case licenseList(LicenseListFeature)
  }

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public var version = "v3.0.0"
    public var visiblePrivacyOptionsRequirements = false
    public var isLoadingConsentForm = false
    public var path: StackState<Path.State> = .init()
    public var safariURL: SafariURL?

    // MARK: - Safari
    public enum SafariURL: Identifiable, Sendable {
      case privacyPolicy
      case termsOfUse
      case userdataExternalTransmission
      case contactDeveloper
      case gitHub
      case googleForm
      case reviewAppStore

      // MARK: - Properties
      public var id: String { url.absoluteString }

      public var url: URL {
        switch self {
        case .privacyPolicy:
          URL(string: "https://github.com/nnsnodnb/nowplaying-ios/wiki/Privacy-Policy")!
        case .termsOfUse:
          URL(string: "https://github.com/nnsnodnb/nowplaying-ios/wiki/Terms-of-use")!
        case .userdataExternalTransmission:
          URL(string: "https://nnsnodnb.moe/userdata-external-transmission/?app=moe.nnsnodnb.NowPlaying")!
        case .contactDeveloper:
          URL(string: "https://x.com/nnsnodnb")!
        case .gitHub:
          URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!
        case .googleForm:
          URL(string: "https://forms.gle/ieuzQgWQE7fD2gYK9")!
        case .reviewAppStore:
          URL(string: "https://itunes.apple.com/jp/app/id1289764391?mt=8&action=write-review")!
        }
      }
    }
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case close
    case pushTwitterSetting
    case pushBlueskySetting
    case pushPaidContent
    case showConsentForm
    case pushLicenseList
    case path(StackActionOf<Path>)
    case openSafari(State.SafariURL?)
    case delegate(Delegate)
    case internalAction(InternalAction)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case hideAds
    }

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case loadConsentForm
      case loadedConsentForm
    }
  }

  // MARK: - Dependency
  @Dependency(\.bundle)
  private var bundle
  @Dependency(\.consentInformation)
  private var consentInformation
  @Dependency(\.dismiss)
  private var dismiss

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.version = bundle.shortVersionString()
        state.visiblePrivacyOptionsRequirements = consentInformation.visiblePrivacyOptionsRequirements()
        if state.visiblePrivacyOptionsRequirements {
          return .send(.internalAction(.loadConsentForm))
        } else {
          return .none
        }
      case .close:
        return .run { _ in
          await dismiss()
        }
      case .pushTwitterSetting:
        state.path.append(.twitterSetting(.init(socialService: .twitter)))
        return .none
      case .pushBlueskySetting:
        state.path.append(.blueskySetting(.init(socialService: .bluesky)))
        return .none
      case .pushPaidContent:
        state.path.append(.paidContent(.init()))
        return .none
      case .showConsentForm:
        guard state.visiblePrivacyOptionsRequirements && !state.isLoadingConsentForm else { return .none }
        return .run(
          operation: { send in
            try await consentInformation.presentPrivacyOptions()
            await send(.internalAction(.loadConsentForm))
          },
          catch: { _, send in
            await send(.internalAction(.loadConsentForm))
          },
        )
      case .pushLicenseList:
        state.path.append(.licenseList(.init()))
        return .none
      case .path(.element(id: _, action: .twitterSetting(.delegate(.pushTwitterAccountManage)))):
        state.path.append(.twitterAccountManage(.init()))
        return .none
      case .path(.element(id: _, action: .blueskySetting(.delegate(.pushBlueskyAccountManage)))):
        state.path.append(.blueskyAccountManage(.init()))
        return .none
      case .path(.element(id: _, action: .paidContent(.delegate(.hideAds)))):
        return .send(.delegate(.hideAds))
      case .path:
        return .none
      case let .openSafari(safariURL):
        state.safariURL = safariURL
        return .none
      case .delegate:
        return .none
      case .internalAction(.loadConsentForm):
        guard state.visiblePrivacyOptionsRequirements else { return .none }
        state.isLoadingConsentForm = true
        return .run(
          operation: { send in
            try await consentInformation.load()
            await send(.internalAction(.loadedConsentForm))
          },
        )
      case .internalAction(.loadedConsentForm):
        state.isLoadingConsentForm = false
        return .none
      case .internalAction:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}

// MARK: - SettingFeature.Path.State Equatable
extension SettingFeature.Path.State: Equatable {}

public struct SettingPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<SettingFeature>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      path: $store.scope(state: \.path, action: \.path),
      root: {
        form
          .navigationTitle("設定")
          .toolbar(
            closeAction: {
              store.send(.close)
            },
          )
          .onAppear {
            store.send(.onAppear)
          }
          .safariView(
            item: $store.safariURL.sending(\.openSafari),
            content: { safariURL in
              SafariView(url: safariURL.url)
                .dismissButtonStyle(.close)
            },
          )
      },
      destination: { store in
        switch store.case {
        case let .twitterSetting(store):
          SocialServiceSettingPage(store: store)
        case let .twitterAccountManage(store):
          TwitterAccountManagePage(store: store)
        case let .blueskySetting(store):
          SocialServiceSettingPage(store: store)
        case let .blueskyAccountManage(store):
          BlueskyAccountManagePage(store: store)
        case let .paidContent(store):
          PaidContentPage(store: store)
        case let .licenseList(store):
          LicenseListPage(store: store)
        }
      },
    )
  }

  private var form: some View {
    Form {
      firstSection
      secondSection
      thirdSection
      fourthSection
    }
  }

  private var firstSection: some View {
    Section {
      buttonRow(
        action: {
          store.send(.pushTwitterSetting)
        },
        title: "X設定",
        icon: {
          Image(.icXTwitterPadding)
            .resizable()
            .aspectRatio(contentMode: .fit)
        },
      )
      buttonRow(
        action: {
          store.send(.pushBlueskySetting)
        },
        title: "Bluesky設定",
        icon: {
          Image(.icBlueskyPadding)
            .resizable()
            .aspectRatio(contentMode: .fit)
        },
      )
    }
  }

  private var secondSection: some View {
    Section {
      buttonRow(
        action: {
          store.send(.pushPaidContent)
        },
        title: "有料コンテンツ",
        icon: {
          Image(systemSymbol: .crownFill)
            .resizable()
            .foregroundStyle(.yellow)
            .aspectRatio(contentMode: .fit)
        },
      )
      buttonRow(
        action: {
          store.send(.openSafari(.termsOfUse))
        },
        title: "利用規約",
        icon: {
          Image(systemSymbol: .textDocumentFill)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.gray.opacity(0.5))
        },
      )
    }
  }

  private var thirdSection: some View {
    Section {
      if store.visiblePrivacyOptionsRequirements {
        buttonRow(
          action: {
            store.send(.showConsentForm)
          },
          title: "Privacy Settings",
          icon: {
            if store.isLoadingConsentForm {
              ProgressView()
                .progressViewStyle(.circular)
            } else {
              Image(systemSymbol: .handRaisedSquareFill)
                .resizable()
                .foregroundStyle(.white, .red.opacity(0.9))
            }
          },
        )
        .disabled(store.isLoadingConsentForm)
      }
      ButtonRow(
        action: {
          store.send(.openSafari(.privacyPolicy))
        },
        title: "プライバシーポリシー",
        icon: {
          Image(systemSymbol: .handRaisedFill)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.blue)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.userdataExternalTransmission))
        },
        title: "データの外部送信について",
        icon: {
          Image(systemSymbol: .network)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.cyan)
        }
      )
    }
  }

  private var fourthSection: some View {
    Section {
      ButtonRow(
        action: {
          store.send(.openSafari(.contactDeveloper))
        },
        title: "開発者",
        icon: {
          Image(.icXTwitterPadding)
            .resizable()
            .aspectRatio(contentMode: .fit)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.gitHub))
        },
        title: "ソースコード",
        icon: {
          Image(.icGithub)
            .resizable()
            .aspectRatio(contentMode: .fit)
        },
      )
      ButtonRow(
        action: {
          store.send(.pushLicenseList)
        },
        title: "ライセンス",
        icon: {
          Image(systemSymbol: .listBulletRectangleFill)
            .resizable()
            .foregroundStyle(.green)
            .aspectRatio(contentMode: .fit)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.googleForm))
        },
        title: "機能要望・バグ報告",
        icon: {
          Image(systemSymbol: .exclamationmarkBubbleFill)
            .resizable()
            .foregroundStyle(.indigo)
            .aspectRatio(contentMode: .fit)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.reviewAppStore))
        },
        title: "レビューする",
        icon: {
          Image(systemSymbol: .starBubble)
            .resizable()
            .foregroundStyle(.purple)
            .aspectRatio(contentMode: .fit)
        },
      )
      versionRow
    }
  }

  private var versionRow: some View {
    HStack(alignment: .center, spacing: 0) {
      Label(
        title: {
          Text("バージョン")
            .foregroundStyle(Color.primary)
        },
        icon: {
          Image(systemSymbol: .tagFill)
            .resizable()
            .foregroundStyle(.yellow)
            .aspectRatio(contentMode: .fit)
        }
      )
      Spacer()
      Text(store.version)
        .foregroundStyle(.secondary)
    }
  }

  private func buttonRow(
    action: @escaping @MainActor () -> Void,
    title: String,
    @ViewBuilder icon: () -> some View,
  ) -> some View {
    Button(
      action: action,
      label: {
        HStack(alignment: .center, spacing: 0) {
          Label(
            title: {
              Text(title)
                .foregroundStyle(Color.primary)
            },
            icon: icon,
          )
          Spacer()
          chevronAnchor
        }
      },
    )
  }

  private var chevronAnchor: some View {
    Image(systemSymbol: .chevronRight)
      .font(.system(size: 14, weight: .semibold))
      .foregroundStyle(Color.secondary)
      .opacity(0.5)
  }
}

private extension View {
  func toolbar(closeAction: @escaping @MainActor () -> Void) -> some View {
    toolbar {
      ToolbarItem(placement: .cancellationAction) {
        CancellationButton(
          action: closeAction,
        )
      }
    }
  }
}

#Preview {
  SettingPage(
    store: .init(
      initialState: SettingFeature.State(),
      reducer: {
        SettingFeature()
      },
    ),
  )
}
