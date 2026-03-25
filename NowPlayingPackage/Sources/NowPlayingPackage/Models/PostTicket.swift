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
    case packageID = "package_id"
    case discount
  }

  // MARK: - Properties
  public let id: ID
  public let ticketCount: Int
  public let price: Int
  public let packageID: PackageID
  public let discount: String?
}
