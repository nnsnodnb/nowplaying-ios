# nowplaying-ios

[![Swift 5.2](https://img.shields.io/badge/language-Swift5.2-orange.svg)](https://developer.apple.com/swift)
![GitHub](https://img.shields.io/github/license/nnsnodnb/nowplaying-ios.svg)
[![Build Status](https://app.bitrise.io/app/8eca75fbd7da8604/status.svg?token=yseu5iRESgLabX5CHEjvWg)](https://app.bitrise.io/app/8eca75fbd7da8604)

NowPlaying tweet & toot application for iOS

## Environments

- Xcode 13.3.1
  - Swift 5.6
- Mint 0.17.1
  - Carthage 0.38.0
  - LicensePlist 3.22.0
  - R.swift v5.2.0
  - SwiftLint 0.47.1
  - XcodeGen 2.15.1

## Installation

```bash
$ git clone --recursive https://github.com/nnsnodnb/nowplaying-ios.git
```

Please copy **Configuration Settings Files**.

```bash
$ cp NowPlaying/Resources/Config/NowPlaying-Debug.xcconfig.sample NowPlaying/Resources/Config/NowPlaying-Debug.xcconfig
$ cp NowPlaying/Resources/Config/NowPlaying-Release.xcconfig.sample NowPlaying/Resources/Config/NowPlaying-Release.xcconfig
```

And please fill your environment variables.

```bash
$ mint bootstrap
$ mint run carthage bootstrap --platform iOS --cache-builds --no-use-binaries --use-xcframeworks
$ mint run xcodegen generate
$ open NowPlaying.xcworkspace
```

## Links

[Requests from end-users](https://docs.google.com/spreadsheets/d/1oNtyJ2x1G-2ZDktxT-jpo1I-8Wqif4Xhc40lH40Crrw/edit?usp=sharing)

## LICENSE

This software is licensed under the MIT License (See [LICENSE](LICENSE)).

## Author

Yuya Oka ([nnsnodnb](https://github.com/nnsnodnb))
