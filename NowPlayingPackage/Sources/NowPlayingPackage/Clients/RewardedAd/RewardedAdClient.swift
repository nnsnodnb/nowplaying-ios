//
//  RewardedAdClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/17.
//

import Dependencies
import DependenciesMacros
import Foundation
import GoogleMobileAds

@DependencyClient
public struct RewardedAdClient: Sendable {
  public var load: @Sendable (String) async throws -> Void
  public var show: @Sendable (String) async throws -> Int

  // MARK: - Error
  public enum Error: Swift.Error {
    case interruption
    case loadError(String)
  }
}

// MARK: - DependencyKey
extension RewardedAdClient: DependencyKey {
  public static let liveValue: Self = .init(
    load: { adUnitID in
      try await Implementation.shared.load(adUnitID: adUnitID)
    },
    show: { adUnitID in
      try await Implementation.shared.show(adUnitID: adUnitID)
    },
  )
}

// MARK: - Implementation
private extension RewardedAdClient {
  final actor Implementation: GlobalActor {
    // MARK: - State
    private enum State {
      case idle
      case loading
      case ready(any RewardedAdProtocol)
      case failed(String)
    }

    // MARK: - Properties
    static let shared: Implementation = .init()

    private let delegate: LockIsolated<Delegate?> = .init(nil)
    private let state: LockIsolated<State> = .init(.idle)
    private let earnedReward: LockIsolated<Bool> = .init(false)

    // MARK: - Dependency
    @Dependency(\.continuousClock)
    private var continuousClock
    @Dependency(\.crashlytics)
    private var crashlytics

    // MARK: - Delegate
    final class Delegate: NSObject, FullScreenContentDelegate, Sendable {
      // MARK: - Properties
      let earnRewarded: @Sendable (Int) -> Void

      // MARK: - Initialize
      init(earnRewarded: @Sendable @escaping (Int) -> Void) {
        self.earnRewarded = earnRewarded
      }

      // MARK: - FullScreenContentDelegate
      // swiftlint:disable:next identifier_name
      func adDidDismissFullScreenContent(_ ad: any FullScreenPresentingAd) {
        guard let rewardedAd = ad as? RewardedAd else { return }
        earnRewarded(rewardedAd.adReward.amount.intValue)
      }
    }

    func load(adUnitID: String) async throws {
      var retryCount = 0
      while retryCount < 5 {
        switch state.value {
        case .idle:
          state.setValue(.loading)
          do {
            let rewardedAd = try await RewardedAd.load(with: adUnitID, request: .init())
            state.setValue(.ready(rewardedAd))
            return
          } catch {
            retryCount += 1
            state.setValue(.failed(error.localizedDescription))
            try? crashlytics.recordRewardedAdLoadError(error)
            try? await continuousClock.sleep(for: .milliseconds(500))
            state.setValue(.idle)
          }
        case .loading, .ready:
          return
        case let .failed(errorDescription):
          state.setValue(.idle)
          throw Error.loadError(errorDescription)
        }
      }
    }

    @MainActor
    func show(adUnitID: String) async throws -> Int {
      earnedReward.setValue(false)
      if case let .ready(rewardedAd) = state.value, rewardedAd.adUnitID == adUnitID {
        try rewardedAd.canPresent()
        return try await withCheckedThrowingContinuation { [weak self] continuation in
          let delegate = Delegate { [weak self] amount in
            if self?.earnedReward.value == true {
              continuation.resume(returning: amount)
            } else {
              self?.state.setValue(.idle)
              continuation.resume(throwing: Error.interruption)
            }
            self?.delegate.setValue(nil)
          }
          self?.delegate.setValue(delegate)
          rewardedAd.present(delegate: delegate) { [weak self] in
            self?.state.setValue(.idle)
            self?.earnedReward.setValue(true)
          }
        }
      }
      try await load(adUnitID: adUnitID)
      return try await show(adUnitID: adUnitID)
    }
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var rewardedAd: RewardedAdClient {
    get {
      self[RewardedAdClient.self]
    }
    set {
      self[RewardedAdClient.self] = newValue
    }
  }
}
