platform :ios, '16.0'
source 'https://cdn.cocoapods.org/'
inhibit_all_warnings!

target 'NowPlaying' do
  use_frameworks!

  pod 'Action'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'IBLinter'
  pod 'KRProgressHUD'
  pod 'LicensePlist'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxRelay'
  pod 'RxSwift'
  pod 'SFSafeSymbols'
  pod 'ScrollFlowLabel'
  pod 'SnapKit'
  pod 'SwiftGen'
  pod 'SwiftLint'

  target 'NowPlayingTests' do
    inherit! :search_paths

    pod 'RxTest'
  end

end

def version(number)
  Gem::Version.create(number)
end

post_install do |project|
  project.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # IPHONEOS_DEPLOYMENT_TARGET
      if version(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']) < version('11.0')
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      end
      # EXCLUDED_ARCHS
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      # ONLY_ACTIVE_ARCH
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      end
    end
  end
end
