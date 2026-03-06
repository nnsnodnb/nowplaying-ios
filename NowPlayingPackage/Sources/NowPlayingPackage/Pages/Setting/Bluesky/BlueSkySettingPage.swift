//
//  BlueSkySettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct BlueSkySettingFeature: Sendable {
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

public struct BlueSkySettingPage: View {
  // MARK: - Properties
  public let store: StoreOf<BlueSkySettingFeature>

  // MARK: - Body
  public var body: some View {
    Text("Bluesky")
      .interactiveDismissDisabled(true)
  }
}

#Preview {
  BlueSkySettingPage(
    store: .init(
      initialState: BlueSkySettingFeature.State(),
      reducer: {
        BlueSkySettingFeature()
      },
    )
  )
}
