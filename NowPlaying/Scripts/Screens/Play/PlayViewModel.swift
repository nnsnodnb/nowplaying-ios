//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/02.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation

struct PlayViewModelInput {

}

// MARK: - PlayViewModelOutput

protocol PlayViewModelOutput {

}

// MARK: - PlayViewModelType

protocol PlayViewModelType {

    var outputs: PlayViewModelOutput { get }
    init(inputs: PlayViewModelInput)
}

final class PlayViewModel: PlayViewModelType {

    var outputs: PlayViewModelOutput { return self }

    init(inputs: PlayViewModelInput) {

    }
}

// MARK: - PlayViewModelOutput

extension PlayViewModel: PlayViewModelOutput {

}
