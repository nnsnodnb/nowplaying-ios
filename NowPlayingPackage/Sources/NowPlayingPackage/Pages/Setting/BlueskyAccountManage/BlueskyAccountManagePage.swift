//
//  BlueskyAccountManagePage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct BlueskyAccountManageFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
  }

  // MARK: - Action
  public enum Action {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
//    Reduce { state, action in
//    }
    EmptyReducer()
  }
}

public struct BlueskyAccountManagePage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<BlueskyAccountManageFeature>

  // MARK: - Body
  public var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

#Preview {
  BlueskyAccountManagePage(
    store: .init(
      initialState: BlueskyAccountManageFeature.State(),
      reducer: {
        BlueskyAccountManageFeature()
      },
    ),
  )
}
