# nowplaying-ios

[![Swift 5.0.1](https://img.shields.io/badge/language-Swift%205.0.1-orange.svg)](https://developer.apple.com/swift)
![GitHub](https://img.shields.io/github/license/nnsnodnb/nowplaying-ios.svg)
[![Build Status](https://app.bitrise.io/app/46e890b35211fd70/status.svg?token=eG6YD8x7X8SU2glJTGMMGg&branch=deploygate)](https://app.bitrise.io/app/46e890b35211fd70)

NowPlaying tweet & toot application for iOS.

## Environments

- Xcode 10.2.1
  - Swift 5.0.1
- Ruby 2.5.3
  - Bundler 2.0.2
    - Cocoapods 1.7.3
- Carthage 0.33.0 and higher

## Installation

```bash
$ gem install bundler -N
$ bundle install --path vendor/bundle
$ bundle exec pod install --repo-update
$ carthage bootstrap --platform iOS --cache-builds
$ open NowPlaying.xcworkspace
```

Please copy **Configuration Settings Files**.

```bash
$ cp NowPlaying/Resources/Config/NowPlaying-Debug.xcconfig.sample NowPlaying/Resources/Config/NowPlaying-Debug.xcconfig
$ cp NowPlaying/Resources/Config/NowPlaying-Release.xcconfig.sample NowPlaying/Resources/Config/NowPlaying-Release.xcconfig
```

And fill your environment variables.

## LICENSE

[MIT LICENSE](LICENSE)

## Author

Yuya Oka ([nnsnodnb](https://github.com/nnsnodnb))

