# nowplaying-ios

## Environment

### Xcode

```command
$ xcodebuild -version
Xcode 26.5
Build version 17F42
```

### Ruby

```command
$ ruby -v
ruby 4.0.5 (2026-05-20 revision 64336ffd0e) +PRISM [arm64-darwin25]
```

## Setup

```sh
$ git clone git@github.com:nnsnodnb/nowplaying-ios.git
$ cd nowplaying-ios
$ xed .
```

### Certificates

If you accessable certificate management repository.

```sh
$ bundle exec fastlane ios setup_development_certificates
```

## Links

- [Requests from end-users](https://docs.google.com/spreadsheets/d/1oNtyJ2x1G-2ZDktxT-jpo1I-8Wqif4Xhc40lH40Crrw/edit?usp=sharing)

## License

This software is licensed under the MIT License (See [LICENSE](LICENSE)).

## Author

Yuya Oka ([nnsnodnb](https://github.com/nnsnodnb))
