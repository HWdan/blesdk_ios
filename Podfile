install! 'cocoapods', :warn_for_unused_master_specs_repo => false

platform :ios, '14.0'
use_frameworks!
inhibit_all_warnings!

target 'BleSdkDemo' do
  project 'BleSdkDemo'

  pod 'HwBluetoothSDK', :path => '../bluetooth-sdk-oc'
  pod 'Zip', :path => 'Vendor/Zip'
  pod 'SSZipArchive', :path => 'Vendor/SSZipArchive'
  pod 'WatchfaceSDK', :path => 'Vendor/WatchfaceSDK'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Zip / 预编译 SFDialPlate 等框架按 9.0 对齐，避免 "compiling for iOS 9.0, but module Zip has 13.0"
      dep = (target.name == 'Zip' || target.name == 'SSZipArchive') ? '9.0' : '13.0'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = dep
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES' if target.name == 'Zip'
    end
  end
end
