//
//  Error+AuthError.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2020/05/10.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import Foundation

extension Error {

    var authErrorDescription: String {
        if let authError = self as? AuthError {
            switch authError {
            case .cancel:
                return "ログインをキャンセルしました"
            case .alreadyUser:
                return "既にログインされているユーザです"
            case .unknown:
                return "不明なエラーが発生しました: \(localizedDescription)"
            }
        } else {
            return "ログインエラーが発生しました: \(localizedDescription)"
        }
    }
}
