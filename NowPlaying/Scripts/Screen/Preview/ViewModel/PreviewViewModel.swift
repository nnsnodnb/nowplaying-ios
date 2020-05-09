//
//  PreviewViewModel.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/09.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

protocol PreviewViewModelInput {}

protocol PreviewViewModelOutput {}

protocol PreviewViewModelType: AnyObject {

    var inputs: PreviewViewModelInput { get }
    var outputs: PreviewViewModelOutput { get }
    init(router: PreviewRoutable)
}

final class PreviewViewModel: PreviewViewModelType {

    var inputs: PreviewViewModelInput { return self }
    var outputs: PreviewViewModelOutput { return self }

    init(router: PreviewRoutable) {

    }
}

// MARK: - PreviewViewModelInput

extension PreviewViewModel: PreviewViewModelInput {}

// MARK: - PreviewViewModelOutput

extension PreviewViewModel: PreviewViewModelOutput {}
