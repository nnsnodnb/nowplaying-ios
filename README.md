# nowplaying-ios

## Environment

### Xcode

```command
$ xcodebuild -version
Xcode 27.0
Build version 27A266a
```

### Ruby

```command
$ ruby -v
ruby 4.0.7 (2026-09-15 revision 229531a6cf) +PRISM [arm64-darwin25]
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
