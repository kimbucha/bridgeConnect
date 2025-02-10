platform :ios, '15.0'

workspace 'BridgeConnect'
project 'BridgeConnect.xcodeproj'

use_frameworks! :linkage => :dynamic

target 'BridgeConnect' do
  pod 'GoogleMaps'
  pod 'GooglePlaces'
end

target 'BridgeConnectKit' do
  pod 'GoogleMaps'
  pod 'GooglePlaces'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['VALID_ARCHS'] = 'arm64 x86_64'
      config.build_settings['DEFINES_MODULE'] = 'YES'
      if config.build_settings['WRAPPER_EXTENSION'] == 'bundle'
        config.build_settings['DEVELOPMENT_TEAM'] = ''
      end
    end
  end
end
