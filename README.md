# nowplaying-ios

[![Swift 5.4](https://img.shields.io/badge/language-Swift5.4-orange.svg)](https://developer.apple.com/swift)
![GitHub](https://img.shields.io/github/license/nnsnodnb/nowplaying-ios.svg)
[![Build Status](https://app.bitrise.io/app/8eca75fbd7da8604/status.svg?token=yseu5iRESgLabX5CHEjvWg)](https://app.bitrise.io/app/8eca75fbd7da8604)

NowPlaying tweet & toot application for iOS

## Environments

- Xcode 12.5
  - Swift 5.4
- Mint 0.16.0
  - Carthage 0.38.0
  - LicensePlist 2.15.1
  - R.swift v5.4.0
  - SwiftLint 0.39.2
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
$ mint run carthage bootstrap --platform iOS --cache-builds --no-use-binaries
$ mint run xcodegen generate
$ open NowPlaying.xcworkspace
```

## Links

[Requests from end-users](https://docs.google.com/spreadsheets/d/1oNtyJ2x1G-2ZDktxT-jpo1I-8Wqif4Xhc40lH40Crrw/edit?usp=sharing)

## LICENSE

This software is licensed under the MIT License (See [LICENSE](LICENSE)).

## Author

Yuya Oka ([nnsnodnb](https://github.com/nnsnodnb))
