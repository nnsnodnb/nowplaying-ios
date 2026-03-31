//
//  TwitterAccountManagePage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/09.
//

import BetterSafariView
import ComposableArchitecture
import Dependencies
import SFSafeSymbols
import SVProgressHUD
import SwiftUI

@Reducer
public struct TwitterAccountManageFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    // MARK: - Properties
    public var callbackURLScheme = ""
    public var clientID = ""
    public var twitterAccounts: [TwitterAccount] = []
    public var oauthURL: URL?
    public var codeVerifier: TwitterOAuthClient.CodeVerifier?
    public var isLoading = false
    @Presents public var alert: AlertState<Action.Alert>?
  }

  // MARK: - Action
  public enum Action {
    case onAppear
    case preloadRewardedAds
    case fetchTwitterAccounts
    case showAlertForWatchingAds
    case oauth
    case changeDefaultAccount(TwitterAccount)
    case deleteTwitterAccount(IndexSet)
    case authenticateSuccess(URL)
    case authenticateFailure(any Error)
    case changedOAuthURL(URL?)
    case internalAction(InternalAction)
    case alert(PresentationAction<Alert>)

    // MARK: - InternalAction
    @CasePathable
    public enum InternalAction {
      case fetchedTwitterAccounts([TwitterAccount])
      case requestGetUserMe(TwitterOAuthToken)
      case savedTwitterAccount(TwitterProfile)
      case oauthFailure(String)
    }

    // MARK: - Alert
    @CasePathable
    public enum Alert: Equatable, Sendable {
      case openRewardedAd
    }
  }

  // MARK: - Dependency
  @Dependency(\.adUnit.addTwitterAccountRewardAdUnitID)
  private var adUnitID
  @Dependency(\.analytics)
  private var analytics
  @Dependency(\.rewardedAd)
  private var rewardedAd
  @Dependency(\.secureKeyValueStore)
  private var secureKeyValueStore
  @Dependency(\.twitterAPI)
  private var twitterAPI
  @Dependency(\.twitterOAuth)
  private var twitterOAuth

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.callbackURLScheme = twitterOAuth.getCallbackURLScheme()
        return .send(.fetchTwitterAccounts)
      case .preloadRewardedAds:
        return .run(
          priority: .background,
          operation: { _ in
            try await rewardedAd.load(adUnitID())
          },
        )
      case .fetchTwitterAccounts:
        return .run(
          operation: { send in
            let accounts = try await secureKeyValueStore.getTwitterAccounts()
            await send(.internalAction(.fetchedTwitterAccounts(accounts)))
          },
        )
      case .showAlertForWatchingAds:
        state.alert = AlertState(
          title: {
            TextState(.watchingAnAdIsRequiredToAddAnAccount)
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState(.cancel)
              },
            )
            ButtonState(
              action: .openRewardedAd,
              label: {
                TextState(.watch)
              },
            )
          },
          message: {
            TextState(.pleaseCooperateAsRetrievingUserInformationIncursCosts)
          },
        )
        return .none
      case .oauth:
        guard let (oauthURL, codeVerifier) = try? twitterOAuth.getAuthenticateURL() else { return .none }
        state.oauthURL = oauthURL
        state.codeVerifier = codeVerifier
        return .none
      case let .changeDefaultAccount(twitterAccount):
        guard !twitterAccount.isDefault else { return .none }
        return .run(
          operation: { send in
            var twitterAccount = twitterAccount
            twitterAccount.setDefault()
            try await secureKeyValueStore.updateDefaultTwitterAccount(twitterAccount)
            await send(.fetchTwitterAccounts)
          },
        )
      case let .deleteTwitterAccount(indexSet):
        return .run(
          operation: { [twitterAccounts = state.twitterAccounts] send in
            for twitterAccount in indexSet.compactMap({ twitterAccounts[safe: $0] }) {
              try await secureKeyValueStore.removeTwitterAccount(twitterAccount)
            }
            await send(.fetchTwitterAccounts)
          },
        )
      case let .authenticateSuccess(url):
        guard let codeVerifier = state.codeVerifier else { return .none }
        guard let code = try? twitterOAuth.validateCallbackURL(url, codeVerifier) else {
          return .run(
            operation: { send in
              await analytics.logEvent(.twitterLogin(false))
              await send(.internalAction(.oauthFailure(String(localized: .anInvalidOperationWasPerformed))))
            },
          )
        }
        state.isLoading = true
        state.codeVerifier = nil
        return .run(
          priority: .high,
          operation: { send in
            let oauthToken = try await twitterOAuth.requestAccessToken(codeVerifier, code)
            await send(.internalAction(.requestGetUserMe(oauthToken)))
            await analytics.logEvent(.twitterLogin(true))
          },
          catch: { _, send in
            await send(.internalAction(.oauthFailure(String(localized: .failedToRetrieveAuthenticationInformation))))
            await analytics.logEvent(.twitterLogin(false))
          },
        )
      case let .authenticateFailure(error):
        guard let errorCode = WebAuthenticationSessionError.Code(rawValue: (error as NSError).code),
              errorCode != .canceledLogin else {
          return .none
        }
        return .run(
          operation: { send in
            await send(.internalAction(.oauthFailure(String(localized: .anUnknownErrorHasOccurred))))
            await analytics.logEvent(.twitterLogin(false))
          },
        )
      case let .changedOAuthURL(oauthURL):
        state.oauthURL = oauthURL
        return .none
      case let .internalAction(.fetchedTwitterAccounts(twitterAccounts)):
        state.twitterAccounts = twitterAccounts
        return .run(
          operation: { _ in
            await analytics.setUserProperty(.twitterAccountsCount(twitterAccounts.count))
          },
        )
      case let .internalAction(.requestGetUserMe(oauthToken)):
        return .run(
          priority: .high,
          operation: { send in
            // ここではoauthToken.accessTokenは取得した直後で有効の想定なので直接アクセスする
            let profile = try await twitterAPI.getUserMe(oauthToken.accessToken)
            let twitterAccount = TwitterAccount(profile: profile)
            try await secureKeyValueStore.addTwitterAccount(twitterAccount)
            try await secureKeyValueStore.setTwitterOAuthToken(twitterAccount, oauthToken)
            await send(.internalAction(.savedTwitterAccount(twitterAccount.profile)))
          },
          catch: { _, send in
            await send(.internalAction(.oauthFailure(String(localized: .failedToRetrieveUserInformation))))
          },
        )
      case let .internalAction(.savedTwitterAccount(profile)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(.loggedIn)
          },
          message: {
            TextState("\(profile.name) (@\(profile.username))")
          },
        )
        return .send(.fetchTwitterAccounts)
      case let .internalAction(.oauthFailure(title)):
        state.isLoading = false
        state.alert = AlertState(
          title: {
            TextState(title)
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState(.close)
              },
            )
          },
        )
        return .none
      case .alert(.presented(.openRewardedAd)):
        state.alert = nil
        return .run(
          operation: { send in
            let result = try await rewardedAd.show(adUnitID())
            if result > 0 {
              await send(.oauth)
            }
            await send(.preloadRewardedAds)
          },
          catch: { _, send in
            await send(.preloadRewardedAds)
          },
        )
      case .alert:
        return .none
      }
    }
    .ifLet(\.$alert, action: \.alert)
  }
}

public struct TwitterAccountManagePage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<TwitterAccountManageFeature>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle(.accountManagement)
      .toolbar(
        addAction: {
          store.send(.showAlertForWatchingAds)
        },
      )
      .task {
        store.send(.preloadRewardedAds)
        store.send(.onAppear)
      }
      .webAuthenticationSession(
        item: $store.oauthURL.sending(\.changedOAuthURL),
        content: { url in
          webAuthenticationSession(url: url)
        },
      )
      .alert($store.scope(state: \.$alert, action: \.alert))
      .progress(store.isLoading)
      .analyticsScreen(screenName: .twitterAccountManage)
  }

  @ViewBuilder private var list: some View {
    if store.twitterAccounts.isEmpty {
      empty
    } else {
      List {
        ForEach(store.twitterAccounts, id: \.profile.id) { twitterAccount in
          twitterAccountRow(twitterAccount)
        }
        .onDelete(
          perform: { indexSet in
            store.send(.deleteTwitterAccount(indexSet))
          },
        )
      }
    }
  }

  private var empty: some View {
    ContentUnavailableView(
      label: {
        VStack(alignment: .center, spacing: 24) {
          Image(systemSymbol: .at)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
          Text(.noAccountAvailable)
        }
        .foregroundStyle(.secondary)
      }
    )
    .background {
      Color(UIColor.systemGroupedBackground)
    }
    .ignoresSafeArea(.all)
  }

  private func twitterAccountRow(_ twitterAccount: TwitterAccount) -> some View {
    Button(
      action: {
        store.send(.changeDefaultAccount(twitterAccount))
      },
      label: {
        TwitterProfileRow(
          twitterAccount: twitterAccount,
          showDefaultStar: true,
        )
        .foregroundStyle(Color.primary)
      },
    )
  }

  private func webAuthenticationSession(url: URL) -> WebAuthenticationSession {
    WebAuthenticationSession(
      url: url,
      callbackURLScheme: store.callbackURLScheme,
      onCompletion: { result in
        switch result {
        case let .success(url):
          store.send(.authenticateSuccess(url))
        case let .failure(error):
          store.send(.authenticateFailure(error))
        }
      },
    )
    .prefersEphemeralWebBrowserSession(true)
  }
}

private extension View {
  func toolbar(addAction: @escaping @MainActor () -> Void) -> some View {
    toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(
          action: addAction,
          label: {
            Image(systemSymbol: .atBadgePlus)
          },
        )
      }
    }
  }
}

#Preview {
  TwitterAccountManagePage(
    store: .init(
      initialState: TwitterAccountManageFeature.State(),
      reducer: {
        TwitterAccountManageFeature()
      },
    ),
  )
}
