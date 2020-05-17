//
//  TodayViewModel.swift
//  TodayExtension
//
//  Created by Oka Yuya on 2020/05/17.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation
import MediaPlayer
import RxCocoa
import RxSwift

protocol TodayViewModelInput {

    var fetchNowPlayingItem: PublishRelay<Void> { get }
}

protocol TodayViewModelOutput {

    var artworkImage: Observable<UIImage?> { get }
    var songName: Observable<String> { get }
    var artistName: Observable<String> { get }
    var viewType: Observable<ViewType> { get }
}

protocol TodayViewModelType {

    var inputs: TodayViewModelInput { get }
    var outputs: TodayViewModelOutput { get }
}

final class TodayViewModel: TodayViewModelType {

    let fetchNowPlayingItem: PublishRelay<Void> = .init()

    var inputs: TodayViewModelInput { return self }
    var outputs: TodayViewModelOutput { return self }
    var artworkImage: Observable<UIImage?> {
        return nowPlayingItem.map { $0.artwork?.image }
    }
    var songName: Observable<String> {
        return nowPlayingItem.map { $0.title ?? "" }
    }
    var artistName: Observable<String> {
        return nowPlayingItem.map { $0.artist ?? "" }
    }
    var viewType: Observable<ViewType> {
        return libraryAuthorizationStatus.map { $0 == .authorized ? .common : .denied }.share(replay: 1, scope: .whileConnected)
    }

    private let disposeBag = DisposeBag()
    private let nowPlayingItem: PublishRelay<MPMediaItem> = .init()
    private let libraryAuthorizationStatus: PublishRelay<MPMediaLibraryAuthorizationStatus> = .init()

    init() {
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()

        fetchNowPlayingItem
            .filter { MPMediaLibrary.authorizationStatus() != .authorized }
            .compactMap { MPMusicPlayerController.systemMusicPlayer.nowPlayingItem }
            .bind(to: nowPlayingItem)
            .disposed(by: disposeBag)

        MPMediaLibrary.requestAuthorization { [weak self] (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    guard let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem else { return }
                    self?.nowPlayingItem.accept(nowPlayingItem)
                }
            }
            self?.libraryAuthorizationStatus.accept(status)
        }

        // 曲が変更されたら通知される
        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .compactMap { $0.object as? MPMusicPlayerController }
            .compactMap { $0.nowPlayingItem }
            .share()
            .bind(to: nowPlayingItem)
            .disposed(by: disposeBag)
    }

    deinit {
        MPMusicPlayerController.systemMusicPlayer.endGeneratingPlaybackNotifications()
    }
}

// MARK: - TodayViewModelInput

extension TodayViewModel: TodayViewModelInput {}

// MARK: - TodayViewModelOutput

extension TodayViewModel: TodayViewModelOutput {}
