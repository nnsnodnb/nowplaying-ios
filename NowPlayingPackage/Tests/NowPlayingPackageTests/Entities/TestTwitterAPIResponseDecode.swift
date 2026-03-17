//
//  TestTwitterAPIResponseDecode.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import Foundation
@testable import NowPlayingPackage
import Testing

struct TestTwitterAPIResponseDecode {
  @Test
  func testIt() throws {
    let profileImageURLString = "https://pbs.twimg.com/profile_images/1593438620769488897/3kV4Mtvq_normal.jpg"
    let jsonObject = [
      "data": [
        "id": "1137201750",
        "name": "小泉ひやかし🌻",
        "username": "nnsnodnb",
        "profile_image_url": profileImageURLString,
      ]
    ]

    let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())
    let jsonDecoder = JSONDecoder()
    let response = try jsonDecoder.decode(TwitterAPIResponse<TwitterProfile>.self, from: data)

    #expect(response.data.id == "1137201750")
    #expect(response.data.name == "小泉ひやかし🌻")
    #expect(response.data.username == "nnsnodnb")
    let expectedProfileImageURLString = "https://pbs.twimg.com/profile_images/1593438620769488897/3kV4Mtvq.jpg"
    #expect(response.data.profileImageURL == URL(string: expectedProfileImageURLString))
  }
}
