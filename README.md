# nowplaying-ios

[![Swift 5.2](https://img.shields.io/badge/language-Swift5.2-orange.svg)](https://developer.apple.com/swift)
![GitHub](https://img.shields.io/github/license/nnsnodnb/nowplaying-ios.svg)

NowPlaying tweet & toot application for iOS

## Environments

- Xcode 11.4.1
  - Swift 5.2.2
- Ruby 2.6.5
  - Bundler 2.0.2
    - Cocoapods 1.8.4
- Mint 0.14.2
  - Carthage 0.34.0
  - LicensePlist 2.15.1
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
$ gem install bundler -N
$ bundle install --path vendor/bundle
$ mint run xcodegen generate
$ bundle exec pod install --repo-update
$ open NowPlaying.xcworkspace
```

## LICENSE

This software is licensed under the MIT License (See [LICENSE](LICENSE)).

## Author

Yuya Oka ([nnsnodnb](https://github.com/nnsnodnb))
