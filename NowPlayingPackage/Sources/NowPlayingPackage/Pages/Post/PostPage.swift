//
//  PostPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/20.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct PostFeature: Sendable {
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

public struct PostPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<PostFeature>

  // MARK: - Body
  public var body: some View {
    NavigationStack(
      root: {
        Text("PostPage")
          .navigationTitle("ポストを作成")
          .navigationBarTitleDisplayMode(.inline)
      },
    )
  }
}

#Preview {
  PostPage(
    store: .init(
      initialState: PostFeature.State(),
      reducer: {
        PostFeature()
      },
    ),
  )
}
