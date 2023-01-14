platform :ios, '16.0'
source 'https://cdn.cocoapods.org/'
inhibit_all_warnings!

target 'NowPlaying' do
  use_frameworks!

  pod 'IBLinter', '~> 0.5.0'
  pod 'LicensePlist', '~> 3.23.4'
  pod 'SwiftGen', '~> 6.6.2'
  pod 'SwiftLint', '~> 0.50.3'

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
    end
  end
end
