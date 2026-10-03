//
//  LicenseDetailPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct LicenseDetailFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    public let license: LicensesPlugin.License
  }

  // MARK: - Action
  public enum Action {
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

public struct LicenseDetailPage: View {
  // MARK: - Properties
  public var store: StoreOf<LicenseDetailFeature>

  // MARK: - Body
  public var body: some View {
    form
      .navigationTitle(store.license.name)
      .navigationScrollEdgeEffectSoft()
  }

  private var form: some View {
    Form {
      if let licenseText = store.license.licenseText {
        ScrollView {
          Text(licenseText)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
      }
    }
    .formStyle(.columns)
  }
}

#Preview {
  NavigationStack(
    root: {
      LicenseDetailPage(
        store: .init(
          initialState: LicenseDetailFeature.State(
            license: .init(
              id: "dummy",
              name: "Dummy",
              licenseText: "Dummy license text",
            ),
          ),
          reducer: {
            LicenseDetailFeature()
          },
        ),
      )
    },
  )
}
