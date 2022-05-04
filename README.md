# nowplaying-ios

## Environment

- Xcode 13.3.1
- Ruby 3.0.3 or later

## Setup

```sh
git clone git@github.com:nnsnodnb/nowplaying-ios.git
cd nowplaying-ios
make setup
```

### Secrets files

Multiple files are confidential for this project.

- NowPlaying/Resources/Firebase/GoogleService-Info.plist

### Certificates

```sh
bundle exec fastlane ios setup_development_certificates
```

## Tests

```sh
bundle exec fastlane ios test
```

## Links

- [Requests from end-users](https://docs.google.com/spreadsheets/d/1oNtyJ2x1G-2ZDktxT-jpo1I-8Wqif4Xhc40lH40Crrw/edit?usp=sharing)

## License

This software is licensed under the MIT License (See [LICENSE](LICENSE)).

## Author

Yuya Oka ([nnsnodnb](https://github.com/nnsnodnb))
