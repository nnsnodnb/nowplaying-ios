//
//  TwitterSettingViewModel.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Eureka
import Foundation
import RxCocoa
import RxSwift

protocol TwitterSettingViewModelOutput {

}

protocol TwitterSettingViewModelType {

    var form: Form { get }
}

final class TwitterSettingViewModel: TwitterSettingViewModelType {

    let form: Form

    init() {
        form = Form()

        configureCells()
    }

    // MARK: - Private method

    private func configureCells() {

    }
}
