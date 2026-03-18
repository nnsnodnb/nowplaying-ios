//
//  BlueskySettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct BlueskySettingFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
  }

  // MARK: - Action
  public enum Action {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

public struct BlueskySettingPage: View {
  // MARK: - Properties
  public let store: StoreOf<BlueskySettingFeature>

  // MARK: - Body
  public var body: some View {
    Text("Bluesky")
      .interactiveDismissDisabled(true)
  }
}

#Preview {
  BlueskySettingPage(
    store: .init(
      initialState: BlueskySettingFeature.State(),
      reducer: {
        BlueskySettingFeature()
      },
    )
  )
}
