//
//  BlueskySettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct BlueskySettingFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - AttachImageType
    public enum AttachImageType: String, CaseIterable, Sendable {
      case onlyArtwork
      case screenShot

      // MARK: - Properties
      public var displayName: String {
        switch self {
        case .onlyArtwork:
          "アートワークのみ"
        case .screenShot:
          "再生画面のスクリーンショット"
        }
      }
    }
  }

  // MARK: - Action
  public enum Action {
    // MARK: - CopyFormatType
    @CasePathable
    public enum CopyFormatType: String, CaseIterable, CustomStringConvertible, Sendable {
      case songTitle = "__songtitle__"
      case artist = "__artist__"
      case album = "__album__"

      // MARK: - Properties
      public var description: String {
        switch self {
        case .songTitle:
          "曲名"
        case .artist:
          "歌手名"
        case .album:
          "アルバム名"
        }
      }
    }
  }

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

public struct BlueskySettingPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<BlueskySettingFeature>

  @FocusState private var isActiveKeyboard

  // MARK: - Body
  public var body: some View {
    form
      .navigationTitle("Bluesky設定")
      .interactiveDismissDisabled(true)
      .scrollDismissesKeyboard(.immediately)
      .toolbar(
        keyboardClose: {
          isActiveKeyboard = false
        },
      )
  }

  private var form: some View {
    Form {
      firstSection
      secondSection
    }
  }

  private var firstSection: some View {
    Section {
      ButtonRow(
        action: {
          // TODO: store.send(.pushBlueskyAccountManage)
        },
        title: "アカウント管理",
        icon: {
          Image(systemSymbol: .at)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray.opacity(0.6))
        },
      )
      ToggleRow(
        // TODO: isOn: $store.isAttachImage.sending(\.changedIsAttachImage),
        isOn: .constant(true),
        title: "画像を添付",
        icon: {
          Image(systemSymbol: .photo)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.blue)
        },
      )
      PickerAttachedMediaSourceRow(
        // TODO: selection: $store.attachImageType.sending(\.changedAttachImageType),
        selection: .constant(BlueskySettingFeature.State.AttachImageType.onlyArtwork),
        content: {
          ForEach(BlueskySettingFeature.State.AttachImageType.allCases, id: \.self) { attachImageType in
            Text(attachImageType.displayName)
              .tag(attachImageType)
          }
        },
      )
    }
  }

  private var secondSection: some View {
    Section(
      content: {
        TextEditor(
          // TODO: text: $store.postFormat.sending(\.changedPostFormat),
          text: .constant("postFormat"),
        )
        .frame(height: 120)
        .focused($isActiveKeyboard)
        resetFormatButton
      },
      header: {
        Text("投稿フォーマット")
      },
      footer: {
        copyFormatFooter
          .padding(.top, 8)
      },
    )
  }

  private var resetFormatButton: some View {
    Button(
      action: {
        // TODO: store.send(.resetFormat)
      },
      label: {
        Text("リセットする")
          .frame(maxWidth: .infinity, alignment: .center)
      },
    )
  }

  private var copyFormatFooter: some View {
    HStack(alignment: .center, spacing: 12) {
      VStack(alignment: .center, spacing: 8) {
        ForEach(TwitterSettingFeature.Action.CopyFormatType.allCases, id: \.self) { copyFormatType in
          Button(
            action: {
              // TODO: store.send(.copyFormat(copyFormatType))
            },
            label: {
              Text(verbatim: copyFormatType.rawValue)
                .underline()
                .foregroundStyle(.gray)
                .font(.system(size: 16))
            },
          )
        }
      }
      VStack(alignment: .leading, spacing: 8) {
        ForEach(BlueskySettingFeature.Action.CopyFormatType.allCases, id: \.self) { copyFormatType in
          Text(verbatim: copyFormatType.description)
            .font(.system(size: 16))
        }
      }
    }
  }
}

private extension View {
  func toolbar(keyboardClose: @escaping () -> Void) -> some View {
    toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button(action: keyboardClose) {
          Text("閉じる")
            .bold()
        }
      }
    }
  }
}

#Preview {
  BlueskySettingPage(
    store: .init(
      initialState: BlueskySettingFeature.State(),
      reducer: {
        BlueskySettingFeature()
      },
    )
  )
}
