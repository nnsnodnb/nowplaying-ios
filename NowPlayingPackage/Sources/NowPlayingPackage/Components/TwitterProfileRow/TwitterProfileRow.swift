//
//  TwitterProfileRow.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import NukeUI
import SwiftUI
import Tagged

public struct TwitterProfileRow: View {
  // MARK: - Properties
  public let twitterAccount: TwitterAccount

  // MARK: - Body
  public var body: some View {
    HStack(alignment: .center, spacing: 12) {
      image
      VStack(alignment: .leading, spacing: 4) {
        Text(twitterAccount.profile.name)
          .font(.system(size: 20, weight: .semibold))
        Text("@\(twitterAccount.profile.username)")
          .font(.system(size: 17))
      }
    }
  }

  private var image: some View {
    LazyImage(url: twitterAccount.profile.profileImageURL) { state in
      if state.isLoading {
        ProgressView()
          .progressViewStyle(.circular)
      } else if let image = state.image {
        image
          .resizable()
          .scaledToFill()
          .clipShape(Circle())
      } else {
        Image(systemSymbol: .photoBadgeExclamationmark)
          .resizable()
          .scaledToFit()
          .foregroundStyle(.red)
          .padding(4)
      }
    }
    .frame(width: 48, height: 48)
  }
}
