//
//  SharedKey+Extensions.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/19.
//

import Foundation
import Sharing

public extension SharedKey {
  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Bool> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Int> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Double> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<String> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<[String]> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<URL> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Data> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Date> {
    appStorage(key.rawValue)
  }

  @_disfavoredOverload
  static func appStorage<Value: Codable>(
    _ key: NowPlayingSharedKey
  ) -> Self where Self == AppStorageKey<Value> {
    appStorage(key.rawValue)
  }

  static func appStorage<Value: RawRepresentable<Int>>(
    _ key: NowPlayingSharedKey
  ) -> Self where Self == AppStorageKey<Value> {
    appStorage(key.rawValue)
  }

  static func appStorage<Value: RawRepresentable<String>>(
    _ key: NowPlayingSharedKey
  ) -> Self where Self == AppStorageKey<Value> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Bool?> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Int?> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Double?> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<String?> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<[String]?> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<URL?> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Data?> {
    appStorage(key.rawValue)
  }

  static func appStorage(_ key: NowPlayingSharedKey) -> Self where Self == AppStorageKey<Date?> {
    appStorage(key.rawValue)
  }

  @_disfavoredOverload
  static func appStorage<Value: Codable>(
    _ key: NowPlayingSharedKey
  ) -> Self where Self == AppStorageKey<Value?> {
    appStorage(key.rawValue)
  }

  static func appStorage<Value: RawRepresentable>(
    _ key: NowPlayingSharedKey
  ) -> Self where Value.RawValue == Int, Self == AppStorageKey<Value?> {
    appStorage(key.rawValue)
  }

  static func appStorage<Value: RawRepresentable>(
    _ key: NowPlayingSharedKey
  ) -> Self where Value.RawValue == String, Self == AppStorageKey<Value?> {
    appStorage(key.rawValue)
  }
}

public extension SharedKey {
  static func inMemory<Value>(_ key: NowPlayingSharedKey) -> Self where Self == InMemoryKey<Value> {
    inMemory(key.rawValue)
  }
}
