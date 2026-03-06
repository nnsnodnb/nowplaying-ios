//
//  TwitterSettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct TwitterSettingFeature: Sendable {
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

public struct TwitterSettingPage: View {
  // MARK: - Properties
  public let store: StoreOf<TwitterSettingFeature>

  // MARK: - Body
  public var body: some View {
    Text("Twitter")
      .interactiveDismissDisabled(true)
  }
}

#Preview {
  TwitterSettingPage(
    store: .init(
      initialState: TwitterSettingFeature.State(),
      reducer: {
        TwitterSettingFeature()
      },
    )
  )
}
