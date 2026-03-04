fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios setup_development_certificates

```sh
[bundle exec] fastlane ios setup_development_certificates
```

Fetch Provisioning Profile & Apple Development Certificate

### ios setup_adhoc_certificates

```sh
[bundle exec] fastlane ios setup_adhoc_certificates
```

Fetch Provisioning Profile & Apple Distribution Certificate

### ios setup_appstore_certificates

```sh
[bundle exec] fastlane ios setup_appstore_certificates
```

Fetch Provisioning Profile & Apple Distribution Certificate

### ios adhoc

```sh
[bundle exec] fastlane ios adhoc
```

Gym for AdHoc

### ios release

```sh
[bundle exec] fastlane ios release
```

Gym for AppStore

### ios update_app_version

```sh
[bundle exec] fastlane ios update_app_version
```

Update MARKETING_VERSION & CURRENT_PROJECT_VERSION

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
