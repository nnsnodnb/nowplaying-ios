//
//  TwitterSettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct TwitterSettingFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    fileprivate static let defaultPostFormat = "__songtitle__ / __artist__ #NowPlaying"

    @Shared(.appStorage("is_twitter_attach_image"))
    public var isAttachImage = true
    @Shared(.appStorage("tweet_with_image_type"))
    public var attachImageType: AttachImageType = .onlyArtwork
    @Shared(.appStorage("tweet_format"))
    public var postFormat = Self.defaultPostFormat
  }

  // MARK: - Action
  public enum Action {
    case pushTwitterAccountManage
    case changedIsAttachImage(Bool)
    case changedAttachImageType(AttachImageType)
    case changedPostFormat(String)
    case resetFormat
    case copyFormat(CopyFormatType)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case pushTwitterAccountManage
    }
  }

  // MARK: - Dependency
  @Dependency(\.pasteboard)
  private var pasteboard

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .pushTwitterAccountManage:
        return .send(.delegate(.pushTwitterAccountManage))
      case let .changedIsAttachImage(isAttachImage):
        state.$isAttachImage.withLock { $0 = isAttachImage }
        return .none
      case let .changedAttachImageType(attachImageType):
        state.$attachImageType.withLock { $0 = attachImageType }
        return .none
      case let .changedPostFormat(postFormat):
        state.$postFormat.withLock { $0 = postFormat }
        return .none
      case .resetFormat:
        return .send(.changedPostFormat(State.defaultPostFormat))
      case let .copyFormat(copyFormat):
        return .run(
          operation: { _ in
            pasteboard.setString(copyFormat.rawValue)
          },
        )
      case .delegate:
        return .none
      }
    }
  }
}

public struct TwitterSettingPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<TwitterSettingFeature>

  @FocusState private var isActiveKeyboard

  // MARK: - Body
  public var body: some View {
    form
      .navigationTitle("X設定")
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
          store.send(.pushTwitterAccountManage)
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
        isOn: $store.isAttachImage.sending(\.changedIsAttachImage),
        title: "画像を添付",
        icon: {
          Image(systemSymbol: .photo)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.blue)
        },
      )
      PickerAttachedMediaSourceRow(
        selection: $store.attachImageType.sending(\.changedAttachImageType),
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
          text: $store.postFormat.sending(\.changedPostFormat),
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
        store.send(.resetFormat)
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
              store.send(.copyFormat(copyFormatType))
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
  TwitterSettingPage(
    store: .init(
      initialState: TwitterSettingFeature.State(),
      reducer: {
        TwitterSettingFeature()
      },
    )
  )
}
