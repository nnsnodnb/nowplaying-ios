platform :ios, '14.0'
source 'https://cdn.cocoapods.org/'
inhibit_all_warnings!

target 'NowPlaying' do
  use_frameworks!

  pod 'Action'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'
  pod 'IBLinter'
  pod 'LicensePlist'
  pod 'RxCocoa'
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
      if version(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']) < version('9.0')
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
