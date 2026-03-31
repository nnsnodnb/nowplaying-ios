//
//  SocialServiceSettingPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import ComposableArchitecture
import SwiftUI

@Reducer
public struct SocialServiceSettingFeature: Sendable {
  // MARK: - State
  @ObservableState
  public struct State: Equatable, Sendable {
    // MARK: - Properties
    fileprivate static let defaultPostFormat = "__songtitle__ / __artist__ #NowPlaying"

    public let socialService: SocialService
    @Shared(.appStorage(.twitterIsAttachImage))
    public var isTwitterAttachImage = true
    @Shared(.appStorage(.twitterWithImageType))
    public var twitterAttachImageType: AttachImageType = .onlyArtwork
    @Shared(.appStorage(.twitterPostFormat))
    public var twitterPostFormat = Self.defaultPostFormat
    @Shared(.appStorage(.blueskyIsAttachImage))
    public var isBlueskyAttachImage = true
    @Shared(.appStorage(.blueskyWithImageType))
    public var blueskyAttachImageType: AttachImageType = .onlyArtwork
    @Shared(.appStorage(.blueskyPostFormat))
    public var blueskyPostFormat = Self.defaultPostFormat
  }

  // MARK: - Action
  public enum Action {
    case pushSocialServiceAccountManage
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
      case pushBlueskyAccountManage
    }
  }

  @Dependency(\.pasteboard)
  private var pasteboard

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .pushSocialServiceAccountManage:
        switch state.socialService {
        case .twitter:
          return .send(.delegate(.pushTwitterAccountManage))
        case .bluesky:
          return .send(.delegate(.pushBlueskyAccountManage))
        }
      case let .changedIsAttachImage(isAttachImage):
        switch state.socialService {
        case .twitter:
          state.$isTwitterAttachImage.withLock { $0 = isAttachImage }
        case .bluesky:
          state.$isBlueskyAttachImage.withLock { $0 = isAttachImage }
        }
        return .none
      case let .changedAttachImageType(attachImageType):
        switch state.socialService {
        case .twitter:
          state.$twitterAttachImageType.withLock { $0 = attachImageType }
        case .bluesky:
          state.$blueskyAttachImageType.withLock { $0 = attachImageType }
        }
        return .none
      case let .changedPostFormat(postFormat):
        switch state.socialService {
        case .twitter:
          state.$twitterPostFormat.withLock { $0 = postFormat }
        case .bluesky:
          state.$blueskyPostFormat.withLock { $0 = postFormat }
        }
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

public struct SocialServiceSettingPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<SocialServiceSettingFeature>

  @FocusState private var isFocused

  // MARK: - Body
  public var body: some View {
    form
      .modifier {
        switch store.socialService {
        case .twitter:
          $0.navigationTitle(.xSettings)
        case .bluesky:
          $0.navigationTitle(.blueskySettings)
        }
      }
      .interactiveDismissDisabled(true)
      .scrollDismissesKeyboard(.immediately)
      .toolbar(
        keyboardClose: {
          isFocused = false
        },
      )
      .modifier {
        switch store.socialService {
        case .twitter:
          $0.analyticsScreen(screenName: .twitterSetting)
        case .bluesky:
          $0.analyticsScreen(screenName: .blueskySetting)
        }
      }
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
          store.send(.pushSocialServiceAccountManage)
        },
        title: String(localized: .accountManagement),
        icon: {
          Image(systemSymbol: .at)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.gray.opacity(0.6))
        },
      )
      switch store.socialService {
      case .twitter:
        toggleRow(
          isOn: $store.isTwitterAttachImage.sending(\.changedIsAttachImage),
        )
        pickerAttachedMediaSourceRow(
          selection: $store.twitterAttachImageType.sending(\.changedAttachImageType),
        )
      case .bluesky:
        toggleRow(
          isOn: $store.isBlueskyAttachImage.sending(\.changedIsAttachImage),
        )
        pickerAttachedMediaSourceRow(
          selection: $store.blueskyAttachImageType.sending(\.changedAttachImageType),
        )
      }
    }
  }

  private var secondSection: some View {
    Section(
      content: {
        switch store.socialService {
        case .twitter:
          textEditor(
            text: $store.twitterPostFormat.sending(\.changedPostFormat),
          )
        case .bluesky:
          textEditor(
            text: $store.blueskyPostFormat.sending(\.changedPostFormat),
          )
        }
        resetFormatButton
      },
      header: {
        Text(.postFormat)
      },
      footer: {
        copyFormatFooter
          .padding(.top, 8)
      },
    )
  }

  private func toggleRow(isOn: Binding<Bool>) -> some View {
    ToggleRow(
      isOn: isOn,
      title: String(localized: .attachImage),
      icon: {
        Image(systemSymbol: .photo)
          .resizable()
          .scaledToFit()
          .foregroundStyle(.blue)
      },
    )
  }

  private func pickerAttachedMediaSourceRow(selection: Binding<AttachImageType>) -> some View {
    PickerAttachedMediaSourceRow(
      selection: selection,
      content: {
        ForEach(AttachImageType.allCases, id: \.self) { attachImageType in
          Text(attachImageType.displayName)
            .tag(attachImageType)
        }
      },
    )
  }

  private func textEditor(text: Binding<String>) -> some View {
    TextEditor(text: text)
      .frame(height: 120)
      .focused($isFocused)
  }

  private var resetFormatButton: some View {
    Button(
      action: {
        store.send(.resetFormat)
      },
      label: {
        Text(.reset)
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
          Text(copyFormatType.description)
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
          Text(.close)
            .bold()
        }
      }
    }
  }
}

#Preview {
  SocialServiceSettingPage(
    store: .init(
      initialState: SocialServiceSettingFeature.State(
        socialService: .bluesky,
      ),
      reducer: {
        SocialServiceSettingFeature()
      },
    )
  )
}
