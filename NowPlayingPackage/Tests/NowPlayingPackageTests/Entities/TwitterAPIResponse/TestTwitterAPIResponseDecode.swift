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
  func testTwitterProfileDecode() throws {
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

    #expect(response.data.id == .init("1137201750"))
    #expect(response.data.name == "小泉ひやかし🌻")
    #expect(response.data.username == "nnsnodnb")
    let expectedProfileImageURLString = "https://pbs.twimg.com/profile_images/1593438620769488897/3kV4Mtvq.jpg"
    #expect(response.data.profileImageURL == URL(string: expectedProfileImageURLString))
  }

  @Test
  func testTwitterMediaDecode() async throws {
    let now = Date.now
    try withDependencies {
      $0.date = .constant(now)
    } operation: {
      let jsonObject = [
        "data": [
          "media_key": "3_2034250625912016896",
          "id": "2034250625912016896",
          "size": 37523,
          "image": [
            "w": 600,
            "image_type": "image/jpeg",
            "h": 600
          ],
          "expires_after_secs": 86400,
        ],
      ]

      let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .init())
      let jsonDecoder = JSONDecoder()
      let response = try jsonDecoder.decode(TwitterAPIResponse<TwitterMedia>.self, from: data)

      #expect(response.data.id == .init("2034250625912016896"))
      #expect(response.data.expiresAfterSecs == 86_400)
      #expect(response.data.isExpired == false)
    }
  }
}
