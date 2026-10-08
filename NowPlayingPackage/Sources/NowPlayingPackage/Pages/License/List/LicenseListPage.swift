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
    case pushLicenseDetail(LicensesPlugin.License)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case pushLicenseDetail(LicensesPlugin.License)
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { _, action in
      switch action {
      case let .pushLicenseDetail(license):
        return .send(.delegate(.pushLicenseDetail(license)))
      case .delegate:
        return .none
      }
    }
  }
}

public struct LicenseListPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<LicenseListFeature>

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle(.licenses)
      .navigationScrollEdgeEffectSoft()
      .interactiveDismissDisabled(true)
      .analyticsScreen(screenName: .license)
  }

  private var list: some View {
    List {
      ForEach(store.licenses) { license in
        Button(
          action: {
            store.send(.pushLicenseDetail(license))
          },
          label: {
            Text(license.name)
              .foregroundStyle(Color.primary)
              .frame(maxWidth: .infinity, alignment: .leading)
          },
        )
      }
    }
  }
}

#Preview {
  NavigationStack(
    root: {
      LicenseListPage(
        store: .init(
          initialState: LicenseListFeature.State(),
          reducer: {
            LicenseListFeature()
          },
        ),
      )
    },
  )
}
