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
    public let isLoading = false
  }

  // MARK: - Action
  public enum Action {
    case purchaseHideAds
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .purchaseHideAds:
        return .none
      }
    }
  }
}

public struct PaidContentPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<PaidContentFeature>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle("有料コンテンツ")
      .interactiveDismissDisabled(true)
      .progress(store.isLoading)
  }

  private var list: some View {
    List {
      section
    }
  }

  private var section: some View {
    Section {
      hideAdsRow
    }
  }

  private var hideAdsRow: some View {
    ButtonRow(
      action: {
        store.send(.purchaseHideAds)
      },
      title: "バナー広告の削除",
      icon: {
        Image(systemSymbol: .eyeSlash)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .foregroundStyle(.red)
      },
    )
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
