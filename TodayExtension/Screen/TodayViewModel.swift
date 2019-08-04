//
//  TodayViewModel.swift
//  TodayExtension
//
//  Created by Yuya Oka on 2019/07/15.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import MediaPlayer
import RxCocoa
import RxSwift

enum ViewType {
    case common
    case denied
}

protocol TodayViewModelInput {

    var accessMusicLibraryTrigger: PublishRelay<Void> { get }
}

// MARK: - TodayViewModelOutput

protocol TodayViewModelOutput {

    var nowPlayingItem: Driver<MPMediaItem> { get }
    var viewType: Observable<ViewType> { get }
}

// MARK: - TodayViewModelType

protocol TodayViewModelType {

    var inputs: TodayViewModelInput { get }
    var outputs: TodayViewModelOutput { get }
    init()
}

final class TodayViewModel: TodayViewModelType {

    var inputs: TodayViewModelInput { return self }
    var outputs: TodayViewModelOutput { return self }

    let accessMusicLibraryTrigger = PublishRelay<Void>()
    let nowPlayingItem: Driver<MPMediaItem>
    let viewType: Observable<ViewType>

    private let disposeBag = DisposeBag()
    private let _nowPlayingItem = PublishSubject<MPMediaItem?>()
    private let _viewType = PublishSubject<ViewType>()

    init() {
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()

        nowPlayingItem = _nowPlayingItem.compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
        viewType = _viewType.observeOn(MainScheduler.instance).asObservable()

        inputs.accessMusicLibraryTrigger
            .subscribe(onNext: { [weak self] in
                self?.setupAccessMusicLibrary()
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            .subscribe(onNext: { [weak self] (notification) in
                guard let player = notification.object as? MPMusicPlayerController else { return }
                self?._nowPlayingItem.onNext(player.nowPlayingItem)
            })
            .disposed(by: disposeBag)

        setupAccessMusicLibrary()
    }

    deinit {
        MPMusicPlayerController.systemMusicPlayer.endGeneratingPlaybackNotifications()
    }
}

// MARK: - Private method

extension TodayViewModel {

    private func setupAccessMusicLibrary() {
        MPMediaLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                // 取得までに時間がかかるので遅延処理
                _ = Observable<Int>.timer(.microseconds(500), scheduler: MainScheduler.instance)
                    .map { _ in }
                    .subscribe(onNext: { [weak self] in
                        self?._nowPlayingItem.onNext(MPMusicPlayerController.systemMusicPlayer.nowPlayingItem)
                        self?._viewType.onNext(.common)
                    })
            case .denied:
                DispatchQueue.main.async { [weak self] in
                    self?._viewType.onNext(.denied)
                }
            case .notDetermined, .restricted:
                break
            @unknown default:
                break
            }
        }
    }
}

// MARK: - TodayViewModelInput

extension TodayViewModel: TodayViewModelInput {}

// MARK: - TodayViewModelOutput

extension TodayViewModel: TodayViewModelOutput {}
