//
//  AnalyticsClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/28.
//

import Dependencies
import DependenciesMacros
import FirebaseAnalytics
import Foundation

@DependencyClient
public struct AnalyticsClient: Sendable {
  public var logEvent: @Sendable (Event) async -> Void = { _ in }
  public var setUserProperty: @Sendable (UserProperty) async -> Void = { _ in }
}

// MARK: - DependencyKey
extension AnalyticsClient: DependencyKey {
  public static let liveValue: Self = .init(
    logEvent: { event in
      Analytics.logEvent(
        event.eventName,
        parameters: event.parameters,
      )
    },
    setUserProperty: { userProperty in
      Analytics.setUserProperty(userProperty.value, forName: userProperty.name)
    },
  )
  public static let testValue: Self = .init(
    logEvent: { _ in },
    setUserProperty: { _ in },
  )
}

// MARK: - ScreenName
public extension AnalyticsClient {
  enum ScreenName: String {
    case root
    case consent
    case play
    case setting
    case twitterSetting = "twitter_setting"
    case twitterAccountManage = "twitter_account_manage"
    case blueskySetting = "bluesky_setting"
    case blueskyAccountManage = "bluesky_account_manage"
    case blueskyLogin = "bluesky_login"
    case mastodonSetting = "mastodon_setting"
    case mastodonAccountManage = "mastodon_account_manage"
    case mastodonLogin = "mastodon_login"
    case paidContent = "paid_content"
    case license
    case tweet
    case post
    case selectTwitterAccount = "select_twitter_account"
    case selectBlueskyAccount = "select_bluesky_account"
    case selectMastodonAccount = "select_mastodon_account"
  }
}

// MARK: - Event
public extension AnalyticsClient {
  enum Event {
    case deniedMusicLibrary
    case emptyPostTicket
    case emptySocialServiceAccount(SocialService)
    case twitterLogin(Bool)
    case twitterPosted(Bool, TwitterProfile.ID, AvailablePostTicket)
    case twitterPostedFailure
    case changedPostableTwitterAccount(Bool)
    case blueskyLogin(Bool, String)
    case blueskyPosted(Bool)
    case blueskyPostedFailure
    case changedPostableBlueskyAccount(Bool)
    case mastodonLogin(Bool, String)
    case mastodonPosted(Bool)
    case mastodonPostedFailure
    case changedPostableMastodonAccount(Bool)
    case purchasedNonConsumableContent(String)
    case restoredPaidContent
    case showGettingFreePostTicketAds(AvailablePostTicket)
    case failedShowGettingFreePostTicketAds(String)
    case purchasedPostTicket(Int, AvailablePostTicket)
    case purchasedBuyMeACoffee
    case getFreePostTicket(AvailablePostTicket)

    // MARK: - Properties
    var eventName: String {
      switch self {
      case .deniedMusicLibrary:
        "denied_music_library"
      case .emptyPostTicket:
        "empty_post_ticket"
      case let .emptySocialServiceAccount(socialService):
        "empty_\(socialService.rawValue.lowercased())_account"
      case .twitterLogin:
        "twitter_login"
      case .twitterPosted:
        "twitter_posted"
      case .twitterPostedFailure:
        "twitter_posted_failure"
      case .changedPostableTwitterAccount:
        "changed_postable_twitter_account"
      case .blueskyLogin:
        "bluesky_login"
      case .blueskyPosted:
        "bluesky_posted"
      case .blueskyPostedFailure:
        "bluesky_posted_failure"
      case .changedPostableBlueskyAccount:
        "changed_postable_bluesky_account"
      case .mastodonLogin:
        "mastodon_login"
      case .mastodonPosted:
        "mastodon_posted"
      case .mastodonPostedFailure:
        "mastodon_posted_failure"
      case .changedPostableMastodonAccount:
        "changed_postable_mastodon_account"
      case .purchasedNonConsumableContent:
        "purchased_non_consumable_content"
      case .restoredPaidContent:
        "restored_paid_content"
      case .showGettingFreePostTicketAds:
        "show_getting_free_post_ticket_ads"
      case .failedShowGettingFreePostTicketAds:
        "failed_show_getting_free_post_ticket_ads"
      case .purchasedPostTicket:
        "purchased_post_ticket"
      case .purchasedBuyMeACoffee:
        "purchased_buy_me_a_coffee"
      case .getFreePostTicket:
        "get_free_post_ticket"
      }
    }

    var parameters: [String: Any]? {
      switch self {
      case .deniedMusicLibrary,
           .emptyPostTicket,
           .emptySocialServiceAccount,
           .twitterPostedFailure,
           .blueskyPostedFailure,
           .mastodonPostedFailure,
           .restoredPaidContent,
           .purchasedBuyMeACoffee:
        nil
      case let .twitterLogin(success):
        [
          "is_success": success ? "true" : "false"
        ]
      case let .twitterPosted(withMedia, twitterProfileID, availablePostTicket):
        [
          "with_media": withMedia ? "true" : "false",
          "twitter_profile_id": twitterProfileID.rawValue,
          "before_remain_free_post_ticket": "\(availablePostTicket.remainingFreeCount)",
          "total_free_post_ticket": "\(availablePostTicket.totalFreeCount)",
          "before_remain_purchased_post_ticket": "\(availablePostTicket.remainingPurchasedCount)",
          "total_purchased_post_ticket": "\(availablePostTicket.totalPurchasedCount)",
        ]
      case let .changedPostableTwitterAccount(isDefault):
        [
          "is_default": isDefault ? "true" : "false",
        ]
      case let .blueskyLogin(success, username):
        [
          "is_success": success ? "true" : "false",
          "username": username,
        ]
      case let .blueskyPosted(withMedia):
        [
          "with_media": withMedia ? "true" : "false",
        ]
      case let .changedPostableBlueskyAccount(isDefault):
        [
          "is_default": isDefault ? "true" : "false",
        ]
      case let .mastodonLogin(success, domain):
        [
          "is_success": success ? "true" : "false",
          "domain": domain,
        ]
      case let .mastodonPosted(withMedia):
        [
          "with_media": withMedia ? "true" : "false",
        ]
      case let .changedPostableMastodonAccount(isDefault):
        [
          "is_default": isDefault ? "true" : "false"
        ]
      case let .purchasedNonConsumableContent(content):
        [
          "content": content,
        ]
      case let .showGettingFreePostTicketAds(availablePostTicket):
        [
          "remain_free_post_ticket": "\(availablePostTicket.remainingFreeCount)",
          "total_free_post_ticket": "\(availablePostTicket.totalFreeCount)",
          "remain_purchased_post_ticket": "\(availablePostTicket.remainingPurchasedCount)",
          "total_purchased_post_ticket": "\(availablePostTicket.totalPurchasedCount)",
        ]
      case let .failedShowGettingFreePostTicketAds(errorDescription):
        [
          "error_detail": errorDescription.prefix(100),
        ]
      case let .purchasedPostTicket(count, availablePostTicket):
        [
          "adding_post_ticket": "\(count)",
          "remain_free_post_ticket": "\(availablePostTicket.remainingFreeCount)",
          "total_free_post_ticket": "\(availablePostTicket.totalFreeCount)",
          "before_remain_purchased_post_ticket": "\(availablePostTicket.remainingPurchasedCount)",
          "before_total_purchased_post_ticket": "\(availablePostTicket.totalPurchasedCount)",
        ]
      case let .getFreePostTicket(availablePostTicket):
        [
          "adding_post_ticket": "1",
          "before_remain_free_post_ticket": "\(availablePostTicket.remainingFreeCount)",
          "before_total_free_post_ticket": "\(availablePostTicket.totalFreeCount)",
          "remain_purchased_post_ticket": "\(availablePostTicket.remainingPurchasedCount)",
          "total_purchased_post_ticket": "\(availablePostTicket.totalPurchasedCount)",
        ]
      }
    }
  }
}

// MARK: - UserProperty
public extension AnalyticsClient {
  enum UserProperty {
    case musicLibraryAccess(Bool)
    case twitterAccountsCount(Int)
    case blueskyAccountsCount(Int)
    case postTwitter
    case postBluesky
    case postMastodon
    case hideBannerAds
    case kindUser(Bool)

    // MARK: - Properties
    var name: String {
      switch self {
      case .musicLibraryAccess:
        "music_library_access"
      case .twitterAccountsCount:
        "twitter_accounts_count"
      case .blueskyAccountsCount:
        "bluesky_accounts_count"
      case .postTwitter:
        "post_twitter"
      case .postBluesky:
        "post_bluesky"
      case .postMastodon:
        "post_mastodon"
      case .hideBannerAds:
        "hide_banner_ads"
      case .kindUser:
        "kind_user"
      }
    }

    var value: String? {
      switch self {
      case let .musicLibraryAccess(authorized):
        authorized ? "true" : "false"
      case let .twitterAccountsCount(count):
        "\(count)"
      case let .blueskyAccountsCount(count):
        "\(count)"
      case .postTwitter:
        "true"
      case .postBluesky:
        "true"
      case .postMastodon:
        "true"
      case .hideBannerAds:
        "true"
      case let .kindUser(success):
        success ? "success" : "failure"
      }
    }
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var analytics: AnalyticsClient {
    get {
      self[AnalyticsClient.self]
    }
    set {
      self[AnalyticsClient.self] = newValue
    }
  }
}
