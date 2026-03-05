//
//  RootPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/04.
//

import ComposableArchitecture
import MemberwiseInit
import SwiftUI

@Reducer
@MemberwiseInit(.public)
public struct RootFeature: Sendable {
  // MARK: - State
  @ObservableState
  @MemberwiseInit(.public)
  public struct State: Equatable {
    public var play: PlayFeature.State = .init()
  }

  // MARK: - Action
  public enum Action {
    case play(PlayFeature.Action)
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Scope(state: \.play, action: \.play) {
      PlayFeature()
    }
    Reduce { _, action in
      switch action {
      case .play:
        return .none
      }
    }
  }
}

@MemberwiseInit(.public)
public struct RootPage: View {
  // MARK: - Properties
  @Init(.public)
  @Bindable public var store: StoreOf<RootFeature>

  // MARK: - Body
  public var body: some View {
    PlayPage(
      store: store.scope(state: \.play, action: \.play)
    )
  }
}

struct RootPage_Previews: PreviewProvider {
  static var previews: some View {
    RootPage(
      store: .init(
        initialState: RootFeature.State(),
        reducer: {
          RootFeature()
        },
      ),
    )
  }
}
