//
//  PostTicket.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import Foundation
import Tagged

public struct PostTicket: Decodable, Equatable, Identifiable, Sendable {
  // MARK: - Tagged
  public typealias ID = Tagged<(Self, id: ()), String>
  public typealias PackageID = Tagged<(Self, packageID: ()), String>

  // MARK: - CodingKeys
  private enum CodingKeys: String, CodingKey {
    case id
    case ticketCount = "ticket_count"
    case price
    case localizedPrice = "localized_price"
    case packageID = "package_id"
    case discount
  }

  // MARK: - Properties
  public let id: ID
  public let ticketCount: Int
  public let price: Int
  public let localizedPrice: LocalizedPrice
  public let packageID: PackageID
  public let discount: String?
}

// MARK: - Properties
public extension PostTicket {
  struct LocalizedPrice: Decodable, Equatable, Sendable {
    // MARK: - CodingKeys
    private enum CodingKeys: String, CodingKey {
      case japanese = "ja"
      case english = "en"
    }

    public let japanese: String
    public let english: String

    public func getLocalePrice() -> String {
      @Dependency(\.locale)
      var locale

      if locale.identifier.lowercased().starts(with: "ja") {
        return japanese
      } else {
        return english
      }
    }
  }
}
