# nowplaying-ios

[![Build Status](https://app.bitrise.io/app/46e890b35211fd70/status.svg?token=eG6YD8x7X8SU2glJTGMMGg&branch=deploygate)](https://app.bitrise.io/app/46e890b35211fd70)

NowPlaying tweet & toot application for iOS.

## Environments

- Xcode 10.2.1
  - Swift 5.0.1
- Ruby 2.5.3
  - Bundler 2.0.1
    - Cocoapods 1.7.1
- Carthage 0.33.0 and higher

## Installation

```bash
$ gem install bundler -N
$ bundle install --path vendor/bundle
$ bundle exec pod install --repo-update
$ carthage bootstrap --platform iOS --cache-builds
```

## LICENSE

[MIT LICENSE](LICENSE)

## Author

Yuya Oka ([nnsnodnb](https://github.com/nnsnodnb))

