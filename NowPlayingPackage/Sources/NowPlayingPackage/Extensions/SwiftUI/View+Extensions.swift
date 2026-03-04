//
//  View+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/04.
//

import SwiftUI

extension View {
  func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
    closure(self)
  }
}
