//
//  PlayViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import Foundation

protocol PlayViewModelInputs: AnyObject {

}

protocol PlayViewModelOutputs: AnyObject {

}

protocol PlayViewModelType: AnyObject {

    var inputs: PlayViewModelInputs { get }
    var outputs: PlayViewModelOutputs { get }
}

final class PlayViewModel: PlayViewModelType {

    // MARK: - Properties
    var inputs: PlayViewModelInputs { return self }
    var outputs: PlayViewModelOutputs { return self }
}

// MARK: - PlayViewModelInputs
extension PlayViewModel: PlayViewModelInputs {}

// MARK: - PlayViewModelOutputs
extension PlayViewModel: PlayViewModelOutputs {}
