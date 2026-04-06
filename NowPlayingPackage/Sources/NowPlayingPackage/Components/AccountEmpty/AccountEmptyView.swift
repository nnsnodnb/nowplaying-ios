//
//  AccountEmptyView.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/04/06.
//

import SwiftUI

public struct AccountEmptyView: View {
  public var body: some View {
    ContentUnavailableView(
      label: {
        VStack(alignment: .center, spacing: 24) {
          Image(systemSymbol: .at)
            .resizable()
            .scaledToFit()
            .frame(width: 50, height: 50)
          Text(.noAccountAvailable)
        }
        .foregroundStyle(.secondary)
      }
    )
    .background {
      Color(UIColor.systemGroupedBackground)
    }
    .ignoresSafeArea(.all)
  }
}

#Preview {
  AccountEmptyView()
}
