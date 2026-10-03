//
//  DetailNilView.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/03.
//

import SwiftUI

public struct DetailNilView: View {
  // MARK: - Properties
  public var text: LocalizedStringResource = .pleaseSelectAnItemFromSidebar

  public var body: some View {
    Text(text)
      .font(.system(size: 20))
      .foregroundStyle(Color.gray)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .backgroundStyle(Color(UIColor.systemGroupedBackground))
  }
}

#Preview {
  DetailNilView()
}
