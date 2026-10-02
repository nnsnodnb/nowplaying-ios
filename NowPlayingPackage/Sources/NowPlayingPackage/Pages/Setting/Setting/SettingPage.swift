//
//  SettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import BetterSafariView
import ComposableArchitecture
import DependenciesInterfaces
import SwiftUI

@Reducer
public struct SettingFeature: Sendable {
  // MARK: - Destination
  @Reducer
  public enum Destination {
    case twitterSetting(SocialServiceSettingFeature)
    case blueskySetting(SocialServiceSettingFeature)
    case mastodonSetting(SocialServiceSettingFeature)
    case paidContent(PaidContentFeature)
    case licenseList(LicenseListFeature)

    // MARK: - Detail
    public enum Detail {
      case twitterSetting
      case blueskySetting
      case mastodonSetting
      case paidContent
      case licenseList
    }
  }

  // MARK: - Path
  @Reducer
  public enum Path {
    case twitterAccountManage(TwitterAccountManageFeature)
    case blueskyAccountManage(BlueskyAccountManageFeature)
    case mastodonAccountManage(MastodonAccountManageFeature)
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
    public var destinationDetail: Destination.Detail?
    @Presents public var destination: Destination.State?

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
        @Dependency(\.locale)
        var locale

        switch self {
        case .privacyPolicy:
          return URL(string: "https://github.com/nnsnodnb/nowplaying-ios/wiki/Privacy-Policy")!
        case .termsOfUse:
          let flag = locale.identifier.lowercased().starts(with: "ja") ? "" : "#english-version"
          return URL(string: "https://github.com/nnsnodnb/nowplaying-ios/wiki/Terms-of-use\(flag)")!
        case .userdataExternalTransmission:
          return URL(string: "https://nnsnodnb.moe/userdata-external-transmission/?app=moe.nnsnodnb.NowPlaying")!
        case .contactDeveloper:
          return URL(string: "https://x.com/nnsnodnb")!
        case .gitHub:
          return URL(string: "https://github.com/nnsnodnb/nowplaying-ios")!
        case .googleForm:
          return URL(string: "https://forms.gle/ieuzQgWQE7fD2gYK9")!
        case .reviewAppStore:
          return URL(string: "https://itunes.apple.com/jp/app/id1289764391?mt=8&action=write-review")!
        }
      }
    }
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case close
    case showDestinationDetail(Destination.Detail?)
    case showConsentForm
    case path(StackActionOf<Path>)
    case openSafari(State.SafariURL?)
    case destination(PresentationAction<Destination.Action>)
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
      case let .showDestinationDetail(destinationDetail):
        state.destinationDetail = destinationDetail
        switch destinationDetail {
        case .twitterSetting:
          state.destination = .twitterSetting(.init(socialService: .twitter))
        case .blueskySetting:
          state.destination = .blueskySetting(.init(socialService: .bluesky))
        case .mastodonSetting:
          state.destination = .mastodonSetting(.init(socialService: .mastodon))
        case .paidContent:
          state.destination = .paidContent(.init())
        case .licenseList:
          state.destination = .licenseList(.init())
        case .none:
          state.destination = nil
        }
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
      case .path:
        return .none
      case let .openSafari(safariURL):
        state.safariURL = safariURL
        return .none
      case .destination(.presented(.twitterSetting(.delegate(.pushTwitterAccountManage)))):
        state.path.append(.twitterAccountManage(.init()))
        return .none
      case .destination(.presented(.blueskySetting(.delegate(.pushBlueskyAccountManage)))):
        state.path.append(.blueskyAccountManage(.init()))
        return .none
      case .destination(.presented(.mastodonSetting(.delegate(.pushMastodonAccountManage)))):
        state.path.append(.mastodonAccountManage(.init()))
        return .none
      case .destination(.presented(.paidContent(.delegate(.hideAds)))):
        return .send(.delegate(.hideAds))
      case .destination:
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
    .ifLet(\.$destination, action: \.destination)
  }
}

// MARK: - SettingFeature.Destination.State Equatable
extension SettingFeature.Destination.State: Equatable {}

// MARK: - SettingFeature.Path.State Equatable
extension SettingFeature.Path.State: Equatable {}

public struct SettingPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<SettingFeature>

  // MARK: - Body
  public var body: some View {
    NavigationSplitView(
      sidebar: {
        list
          .navigationTitle(.settings)
          .navigationScrollEdgeEffectSoft()
          .toolbar(
            closeAction: {
              store.send(.close)
            },
          )
          .task {
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
      detail: {
        if let destination = store.scope(\.destination, action: \.destination.presented) {
          NavigationStack(
            path: $store.scope(\.path, action: \.path),
            root: {
              switch destination.case {
              case let .twitterSetting(store):
                SocialServiceSettingPage(store: store)
              case let .blueskySetting(store):
                SocialServiceSettingPage(store: store)
              case let .mastodonSetting(store):
                SocialServiceSettingPage(store: store)
              case let .paidContent(store):
                PaidContentPage(store: store)
              case let .licenseList(store):
                LicenseListPage(store: store)
              }
            },
            destination: { store in
              switch store.case {
              case let .twitterAccountManage(store):
                TwitterAccountManagePage(store: store)
              case let .blueskyAccountManage(store):
                BlueskyAccountManagePage(store: store)
              case let .mastodonAccountManage(store):
                MastodonAccountManagePage(store: store)
              }
            },
          )
        }
      },
    )
    .analyticsScreen(screenName: .setting)
  }

  private var list: some View {
    List(
      selection: $store.destinationDetail.sending(\.showDestinationDetail),
      content: {
        firstSection
        secondSection
        thirdSection
        fourthSection
      },
    )
  }

  private var firstSection: some View {
    Section {
      buttonRow(
        action: {
          store.send(.showDestinationDetail(.twitterSetting))
        },
        title: .xSettings,
        icon: {
          Image(.icXTwitterPadding)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      buttonRow(
        action: {
          store.send(.showDestinationDetail(.blueskySetting))
        },
        title: .blueskySettings,
        icon: {
          Image(.icBlueskyPadding)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      buttonRow(
        action: {
          store.send(.showDestinationDetail(.mastodonSetting))
        },
        title: .mastodonSetitngs,
        icon: {
          Image(.icMastodon)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
    }
  }

  private var secondSection: some View {
    Section {
      buttonRow(
        action: {
          store.send(.showDestinationDetail(.paidContent))
        },
        title: .paidContent,
        icon: {
          Image(systemSymbol: .crownFill)
            .resizable()
            .foregroundStyle(.yellow)
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      buttonRow(
        action: {
          store.send(.openSafari(.termsOfUse))
        },
        title: .termsOfUse,
        icon: {
          Image(systemSymbol: .textDocumentFill)
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.gray.opacity(0.5))
            .frame(width: 24, height: 24)
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
          title: .privacySettings,
          icon: {
            if store.isLoadingConsentForm {
              ProgressView()
                .progressViewStyle(.circular)
            } else {
              Image(systemSymbol: .handRaisedSquareFill)
                .resizable()
                .foregroundStyle(.white, .red.opacity(0.9))
                .frame(width: 24, height: 24)
            }
          },
        )
        .disabled(store.isLoadingConsentForm)
      }
      ButtonRow(
        action: {
          store.send(.openSafari(.privacyPolicy))
        },
        title: String(localized: .privacyPolicy),
        icon: {
          Image(systemSymbol: .handRaisedFill)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.blue)
            .frame(width: 24, height: 24)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.userdataExternalTransmission))
        },
        title: String(localized: .aboutUserdataExternalTransmission),
        icon: {
          Image(systemSymbol: .network)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.cyan)
            .frame(width: 24, height: 24)
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
        title: String(localized: .developer),
        icon: {
          Image(.icXTwitterPadding)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.gitHub))
        },
        title: String(localized: .sourceCode),
        icon: {
          Image(.icGithub)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      ButtonRow(
        action: {
          store.send(.showDestinationDetail(.licenseList))
        },
        title: String(localized: .licenses),
        icon: {
          Image(systemSymbol: .listBulletRectangleFill)
            .resizable()
            .foregroundStyle(.green)
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.googleForm))
        },
        title: String(localized: .featureRequestsBugReports),
        icon: {
          Image(systemSymbol: .exclamationmarkBubbleFill)
            .resizable()
            .foregroundStyle(.indigo)
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      ButtonRow(
        action: {
          store.send(.openSafari(.reviewAppStore))
        },
        title: String(localized: .writeAReview),
        icon: {
          Image(systemSymbol: .starBubble)
            .resizable()
            .foregroundStyle(.purple)
            .scaledToFit()
            .frame(width: 24, height: 24)
        },
      )
      versionRow
    }
  }

  private var versionRow: some View {
    HStack(alignment: .center, spacing: 0) {
      Label(
        title: {
          Text(.version)
            .foregroundStyle(Color.primary)
        },
        icon: {
          Image(systemSymbol: .tagFill)
            .resizable()
            .foregroundStyle(.yellow)
            .scaledToFit()
            .frame(width: 24, height: 24)
        }
      )
      Spacer()
      Text(store.version)
        .foregroundStyle(.secondary)
    }
  }

  private func buttonRow(
    action: @escaping @MainActor () -> Void,
    title: LocalizedStringResource,
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
