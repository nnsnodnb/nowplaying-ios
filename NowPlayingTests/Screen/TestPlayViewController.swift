//
//  TestPlayViewController.swift
//  NowPlayingTests
//
//  Created by Oka Yuya on 2020/01/23.
//  Copyright © 2020 Yuya Oka. All rights reserved.
//

import FBSnapshotTestCase
import UIKit
import XCTest
@testable import NowPlaying

final class TestPlayViewController: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        recordModel = true
        folderName = "再生画面"
        fileNameOptions = [.screenSize, .screenScale, .OS]
    }
}
