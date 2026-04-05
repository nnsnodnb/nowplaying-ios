//
//  MastodonAccountManagePage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/05.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct MastodonAccountManageFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
  }

  // MARK: - Action
  public enum Action {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

public struct MastodonAccountManagePage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<MastodonAccountManageFeature>

  // MARK: - Body
  public var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

#Preview {
  MastodonAccountManagePage(
    store: .init(
      initialState: MastodonAccountManageFeature.State(),
      reducer: {
        MastodonAccountManageFeature()
      },
    ),
  )
}
