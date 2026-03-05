//
//  ScrollFlowText.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/05.
//

import ScrollFlowLabel
import SwiftUI

public struct ScrollFlowText: View {
  // MARK: - Properties
  @State public var text: String?
  public var textColor: UIColor = .label
  public var font: UIFont = .systemFont(ofSize: 14)

  // MARK: - Body
  public var body: some View {
    ScrollFlowLabelWrapper(
      text: text,
      textColor: textColor,
      font: font,
    )
    .frame(height: font.pointSize)
  }
}

struct ScrollFlowLabelWrapper: UIViewRepresentable {
  // MARK: - Properties
  @State var text: String?
  let textColor: UIColor
  let font: UIFont

  func makeUIView(context: Context) -> ScrollFlowLabel {
    let label = ScrollFlowLabel()
    label.text = text
    label.textColor = .label
    label.font = font
    label.pauseInterval = 2
    label.scrollDirection = .left
    label.scrollSpeed = 20
    label.observeApplicationState()
    return label
  }

  func updateUIView(_ uiView: ScrollFlowLabel, context: Context) {
    uiView.text = text
  }
}

#Preview {
  ScrollFlowLabelWrapper(
    text: "長いテキスト",
    textColor: .label,
    font: .systemFont(ofSize: 20),
  )
}
