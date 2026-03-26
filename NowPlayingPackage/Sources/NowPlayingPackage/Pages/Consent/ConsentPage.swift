//
//  ConsentPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/26.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct ConsentFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
  }

  // MARK: - Action
  public enum Action: Sendable {
    case showConsent
    case completed
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate: Sendable {
      case completedConsent
    }
  }

  // MARK: - Dependency
  @Dependency(\.consentInformation)
  private var consentInformation

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case .showConsent:
        return .run(
          operation: { send in
            guard try await consentInformation.requestConsent() else {
              await send(.completed)
              return
            }
            try await consentInformation.loadAndPresentIfRequired()
            await send(.completed)
          },
        )
      case .completed:
        return .send(.delegate(.completedConsent))
      case .delegate:
        return .none
      }
    }
  }
}

public struct ConsentPage: View {
  // MARK: - Properties
  public let store: StoreOf<ConsentFeature>

  // MARK: - Body
  public var body: some View {
    Color(UIColor.systemBackground.withAlphaComponent(0.000001))
      .ignoresSafeArea(.all)
      .onAppear {
        store.send(.showConsent)
      }
  }
}

#Preview {
  ConsentPage(
    store: .init(
      initialState: ConsentFeature.State(),
      reducer: {
        ConsentFeature()
      },
    ),
  )
}
