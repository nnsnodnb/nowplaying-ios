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
  public let text: String?
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
  let text: String?
  let textColor: UIColor
  let font: UIFont

  func makeUIView(context: Context) -> ScrollFlowLabel {
    let label = ScrollFlowLabel()
    label.text = text
    label.textColor = textColor
    label.font = font
    label.pauseInterval = 2
    label.scrollDirection = .left
    label.scrollSpeed = 20
    label.observeApplicationState()
    return label
  }

  func updateUIView(_ uiView: ScrollFlowLabel, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
    if uiView.textColor != textColor {
      uiView.textColor = textColor
    }
    if uiView.font != font {
      uiView.font = font
    }
  }
}

#Preview {
  ScrollFlowLabelWrapper(
    text: "長いテキスト",
    textColor: .label,
    font: .systemFont(ofSize: 20),
  )
}
