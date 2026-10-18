//
//  BlueskyFacetBuilder.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/18.
//

import Foundation

enum BlueskyFacetBuilder {
  static func hashTag(in text: String) -> [BlueskyFacet]? {
    guard let regex = try? NSRegularExpression(pattern: #"(^|\s)([#＃])(\S+)"#) else { return nil }
    let nsString = text as NSString
    var facets: [BlueskyFacet] = []

    for match in regex.matches(in: text, range: NSRange(location: 0, length: nsString.length)) {
      guard let markRange = Range(match.range(at: 2), in: text),
            let tagRange = Range(match.range(at: 3), in: text) else { continue }

      // 末尾の句読点はタグに含めない
      var tag = String(text[tagRange])
      while let last = tag.unicodeScalars.last,
            CharacterSet.punctuationCharacters.contains(last) {
        tag.removeLast()
      }
      // 空、数字のみ、長すぎるものは除外
      guard !tag.isEmpty,
            tag.count <= 64,
            tag.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil else { continue }
      let start = text.utf8.distance(from: text.startIndex, to: markRange.lowerBound)
      // # + タグ本体のバイト数
      let end = start + "#".utf8.count + tag.utf8.count

      let facet = BlueskyFacet(
        index: .init(byteStart: start, byteEnd: end),
        features: [.init(tag: tag)],
      )
      facets.append(facet)
    }

    return facets.isEmpty ? nil : facets
  }
}
