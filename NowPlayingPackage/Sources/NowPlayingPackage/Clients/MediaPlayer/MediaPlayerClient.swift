//
//  MediaPlayerClient.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/11.
//

import Dependencies
import DependenciesMacros
import Foundation
import MediaPlayer

@DependencyClient
public struct MediaPlayerClient: Sendable {
  public var requestAuthorization: @Sendable () async throws -> Void
  public var backward: @Sendable () async throws -> Void
  public var playback: @Sendable () async throws -> Void
  public var forward: @Sendable () async throws -> Void
  public var nowPlayingItem: @Sendable () async throws -> AsyncStream<(any MediaItemProtocol)?>
  public var playbackState: @Sendable () async throws -> AsyncStream<Bool>

  // MARK: - Error
  public enum Error: Swift.Error {
    case denied
    case restricted
  }
}

// MARK: - DependencyKey
extension MediaPlayerClient: DependencyKey {
  public static let liveValue: Self = .init(
    requestAuthorization: {
      try await Implementation.shared.requestAuthorization()
    },
    backward: {
      await Implementation.shared.backward()
    },
    playback: {
      await Implementation.shared.playback()
    },
    forward: {
      await Implementation.shared.forward()
    },
    nowPlayingItem: {
      await Implementation.shared.nowPlayingItem()
    },
    playbackState: {
      await Implementation.shared.playbackState()
    },
  )
}

// MARK: - Implementation
private extension MediaPlayerClient {
  final actor Implementation: GlobalActor {
    // MARK: - Properties
    static let shared: Implementation = .init()

    @Dependency(\.notificationCenter)
    private var notificationCenter

    private let musicPlayer: any MPMusicPlayerController & MPSystemMusicPlayerController

    // MARK: - Initialize
    init() {
      self.musicPlayer = MPMusicPlayerController.systemMusicPlayer
    }

    func requestAuthorization() async throws {
      switch MPMediaLibrary.authorizationStatus() {
      case .authorized:
        return
      case .denied:
        throw Error.denied
      case .notDetermined:
        switch await MPMediaLibrary.requestAuthorization() {
        case .authorized:
          return
        case .denied:
          throw Error.denied
        case .restricted:
          throw Error.restricted
        default:
            return
        }
      case .restricted:
        throw Error.restricted
      @unknown default:
        return
      }
    }

    func backward() {
      // 3秒以上経過していれば曲の初めに戻す
      if musicPlayer.currentPlaybackTime > 3 {
        musicPlayer.beginSeekingBackward()
      } else {
        musicPlayer.skipToPreviousItem()
      }
    }

    func playback() {
      switch musicPlayer.playbackState {
      case .paused, .stopped, .interrupted:
        musicPlayer.play()
      case .playing:
        musicPlayer.pause()
      default:
        return
      }
    }

    func forward() {
      musicPlayer.skipToNextItem()
    }

    func nowPlayingItem() async -> AsyncStream<(any MediaItemProtocol)?> {
      AsyncStream { continuation in
        musicPlayer.beginGeneratingPlaybackNotifications()
        continuation.yield(musicPlayer.nowPlayingItem)

        let task = Task {
          for await notification in notificationCenter.notifications(named: .MPMusicPlayerControllerNowPlayingItemDidChange) {
            guard let musicPlayer = notification.object as? MPMusicPlayerController else { continue }
            continuation.yield(musicPlayer.nowPlayingItem)
          }
        }
        if task.isCancelled {
          continuation.finish()
          musicPlayer.endGeneratingPlaybackNotifications()
        }

        continuation.onTermination = { _ in
          task.cancel()
        }
      }
    }

    func playbackState() async -> AsyncStream<Bool> {
      AsyncStream { continuation in
        continuation.yield(musicPlayer.playbackState == .playing)

        let task = Task {
          for await notification in notificationCenter.notifications(named: .MPMusicPlayerControllerPlaybackStateDidChange) {
            guard let musicPlayer = notification.object as? MPMusicPlayerController else { continue }
            continuation.yield(musicPlayer.playbackState == .playing)
          }
        }
        if task.isCancelled {
          continuation.finish()
        }

        continuation.onTermination = { _ in
          task.cancel()
        }
      }
    }
  }
}

// MARK: - DependencyValues
public extension DependencyValues {
  var mediaPlayer: MediaPlayerClient {
    get {
      self[MediaPlayerClient.self]
    }
    set {
      self[MediaPlayerClient.self] = newValue
    }
  }
}
