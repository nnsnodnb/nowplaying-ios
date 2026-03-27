//
//  TestPaidContentFeatureShowAlertBeforeAds.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/25.
//

import ComposableArchitecture
@testable import NowPlayingPackage
import Testing

@MainActor
@Suite(
  .dependency(\.defaultAppStorage, .inMemory)
)
struct TestPaidContentFeatureShowAlertBeforeAds {
  @Test
  func testAtFirst() async throws {
    await withDependencies {
      $0.defaultAppStorage = .inMemory
    } operation: {
      let store = TestStore(
        initialState: PaidContentFeature.State(
          earnFreeTicketDate: .init(value: nil),
        ),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.showAlertBeforeAds) {
        $0.alert = AlertState(
          title: {
            TextState("広告を見て無料チケットを獲得しますか？")
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState("キャンセル")
              },
            )
            ButtonState(
              action: .watchAds,
              label: {
                TextState("視聴する")
              },
            )
          },
          message: {
            TextState("視聴できるのは1日1回までです")
          }
        )
      }
    }
  }

  @Test
  func testTodayIsFirst() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let now = Date.now
    let startOfDay = calendar.startOfDay(for: now)
    let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfDay)!

    await withDependencies {
      $0.calendar = calendar
      $0.defaultAppStorage = .inMemory
      $0.date = .constant(now)
    } operation: {
      @Shared(.appStorage(.earnFreeTicketDate))
      var earnFreeTicketDate = yesterday

      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.showAlertBeforeAds) {
        $0.alert = AlertState(
          title: {
            TextState("広告を見て無料チケットを獲得しますか？")
          },
          actions: {
            ButtonState(
              role: .cancel,
              label: {
                TextState("キャンセル")
              },
            )
            ButtonState(
              action: .watchAds,
              label: {
                TextState("視聴する")
              },
            )
          },
          message: {
            TextState("視聴できるのは1日1回までです")
          }
        )
      }
    }
  }

  @Test
  func testAlreadyToday() async throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let dateComponents = DateComponents(year: 2026, month: 3, day: 25, hour: 0, minute: 0, second: 1)
    let now = calendar.date(from: dateComponents)!
    let earnFreeTicketDate = calendar.date(byAdding: .second, value: -1, to: now)!

    await withDependencies {
      $0.calendar = calendar
      $0.defaultAppStorage = .inMemory
      $0.date = .constant(now)
    } operation: {
      @Shared(.appStorage(.earnFreeTicketDate))
      var earnFreeTicketDate = earnFreeTicketDate

      let store = TestStore(
        initialState: PaidContentFeature.State(),
        reducer: {
          PaidContentFeature()
        },
      )

      await store.send(.showAlertBeforeAds) {
        $0.alert = AlertState(
          title: {
            TextState("今日の無料チケットはすでに獲得済みです")
          },
          actions: {
            ButtonState(
              action: .close,
              label: {
                TextState("閉じる")
              },
            )
          },
        )
      }
    }
  }
}
