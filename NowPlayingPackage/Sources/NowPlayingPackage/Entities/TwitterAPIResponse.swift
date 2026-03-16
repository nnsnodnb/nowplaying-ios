//
//  TwitterAPIResponse.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import Foundation

public struct TwitterAPIResponse<T: Decodable & Equatable>: Decodable, Equatable {
  // MARK: - Properties
  public let data: T
}
