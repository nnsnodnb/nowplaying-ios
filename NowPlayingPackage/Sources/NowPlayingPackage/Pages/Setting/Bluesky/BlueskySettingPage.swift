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
    // MARK: - Properties
    fileprivate static let defaultPostFormat = "__songtitle__ / __artist__ #NowPlaying"

    @Shared(.appStorage("is_mastodon_with_image"))
    public var isAttachImage = true
    @Shared(.appStorage("toot_with_image_type"))
    public var attachImageType: AttachImageType = .onlyArtwork
    @Shared(.appStorage("toot_format"))
    public var postFormat = Self.defaultPostFormat
  }

  // MARK: - Action
  public enum Action {
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
        selection: .constant(AttachImageType.onlyArtwork),
        content: {
          ForEach(AttachImageType.allCases, id: \.self) { attachImageType in
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
        ForEach(CopyFormatType.allCases, id: \.self) { copyFormatType in
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
        ForEach(CopyFormatType.allCases, id: \.self) { copyFormatType in
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
