//
//  SwiftUIView.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct LicenseListFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    public let licenses: [LicensesPlugin.License] = LicensesPlugin.licenses
  }

  // MARK: - Action
  public enum Action {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

public struct LicenseListPage: View {
  // MARK: - Properties
  public let store: StoreOf<LicenseListFeature>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle("ライセンス")
      .interactiveDismissDisabled(true)
      .analyticsScreen(screenName: .license)
  }

  private var list: some View {
    List {
      ForEach(store.licenses) { license in
        NavigationLink(
          destination: {
             LicenseDetailPage(license: license)
          },
          label: {
            Text(license.name)
              .foregroundStyle(Color.primary)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        )
      }
    }
  }
}

#Preview {
  LicenseListPage(
    store: .init(
      initialState: LicenseListFeature.State(),
      reducer: {
        LicenseListFeature()
      },
    ),
  )
}
