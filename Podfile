platform :ios, '16.0'
source 'https://cdn.cocoapods.org/'
inhibit_all_warnings!

target 'NowPlaying' do
  use_frameworks!

  pod 'Action', '~> 5.0.0'
  pod 'FirebaseAnalytics', '~> 10.3.0'
  pod 'FirebaseCrashlytics', '~> 10.3.0'
  pod 'IBLinter', '~> 0.5.0'
  pod 'KRProgressHUD', '~> 3.4.7'
  pod 'LicensePlist', '~> 3.23.4'
  pod 'RxCocoa', '~> 6.5.0'
  pod 'RxDataSources', '~> 5.0.0'
  pod 'RxRelay', '~> 6.5.0'
  pod 'RxSwift', '~> 6.5.0'
  pod 'SFSafeSymbols', '~> 4.1.0'
  pod 'ScrollFlowLabel', '~> 1.0.3'
  pod 'SnapKit', '~> 5.6.0'
  pod 'SwiftGen', '~> 6.6.2'
  pod 'SwiftLint', '~> 0.50.3'

  target 'NowPlayingTests' do
    inherit! :search_paths

    pod 'RxTest', '~> 6.5.0'
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
