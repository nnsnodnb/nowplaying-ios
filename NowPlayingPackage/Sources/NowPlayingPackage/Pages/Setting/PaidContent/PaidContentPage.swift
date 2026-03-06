//
//  PaidContentPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct PaidContentFeature: Sendable {
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

public struct PaidContentPage: View {
  // MARK: - Properties
  public let store: StoreOf<PaidContentFeature>

  // MARK: - Body
  public var body: some View {
    Text("PaidContent")
      .interactiveDismissDisabled(true)
  }
}

#Preview {
  PaidContentPage(
    store: .init(
      initialState: PaidContentFeature.State(),
      reducer: {
        PaidContentFeature()
      },
    ),
  )
}
