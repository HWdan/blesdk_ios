Pod::Spec.new do |s|
  s.name             = 'blesdk_ios'
  s.version          = '1.0.0'
  s.swift_version    = '5.0'
  s.summary          = 'blesdk_ios - Aggregate BLE SDK'
  s.description      = 'Aggregation of all Huawo BLE related SDKs'
  s.homepage         = 'https://github.com/HWdan/blesdk_ios.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sujiang' => 'sujiang@huawo-wear.com' }
  s.source           = { :git => 'https://github.com/HWdan/blesdk_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'

  # 1. Zip 子库
  s.subspec 'Zip' do |zip|
    zip.source_files = 'Vendor/Zip/Zip/*.{swift,h}', 'Vendor/Zip/Zip/minizip/*.{c,h}', 'Vendor/Zip/Zip/minizip/include/*.{h}'
    zip.public_header_files = 'Vendor/Zip/Zip/*.h'
    zip.libraries = 'z'
    zip.pod_target_xcconfig = {
      'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Vendor/Zip/Zip/minizip/** $(PODS_TARGET_SRCROOT)/Vendor/Zip/Zip/minizip/**',
      'LIBRARY_SEARCH_PATHS' => '$(inherited) $(PODS_TARGET_SRCROOT)/Vendor/Zip/Zip/'
    }
    zip.preserve_paths = 'Vendor/Zip/Zip/minizip/module/module.modulemap', 'Vendor/Zip/Zip/minizip/include/*'
  end

  # 2. SSZipArchive 子库
  s.subspec 'SSZipArchive' do |ss|
    ss.source_files = 'Vendor/SSZipArchive/SSZipArchive/*.{m,h}', 'Vendor/SSZipArchive/SSZipArchive/include/*.{m,h}', 'Vendor/SSZipArchive/SSZipArchive/minizip/*.{c,h}'
    ss.public_header_files = 'Vendor/SSZipArchive/SSZipArchive/*.h'
    ss.libraries = 'z', 'iconv'
    ss.frameworks = 'Security'
    ss.pod_target_xcconfig = {
      'DEFINES_MODULE' => 'YES',
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HAVE_INTTYPES_H HAVE_PKCRYPT HAVE_STDINT_H HAVE_WZAES HAVE_ZLIB'
    }
  end

  # 3. HwBluetoothSDK 子库 (静态库)
  s.subspec 'HwBluetoothSDK' do |hw|
    hw.preserve_paths = [
      'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework',
      'Vendor/HwBluetoothSDK/include',
      'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a'
    ]
    hw.vendored_libraries = 'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a'
    hw.frameworks = 'CoreBluetooth', 'Foundation', 'UIKit'
    hw.libraries = 'z', 'c++'
    
    root = '${PODS_TARGET_SRCROOT}/Vendor/HwBluetoothSDK'
    header_paths = [
      "\"#{root}/include\"",
      "\"#{root}/include/HwBluetoothSDK\"",
      "\"#{root}/HwBluetoothSDK.framework/Headers\""
    ].join(' ')
    
    hw.pod_target_xcconfig = {
      'HEADER_SEARCH_PATHS' => header_paths,
      'FRAMEWORK_SEARCH_PATHS' => "\"#{root}\"",
      'LIBRARY_SEARCH_PATHS' => "\"#{root}\"",
      'DEFINES_MODULE' => 'YES',
      'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
    }
    hw.user_target_xcconfig = {
      'HEADER_SEARCH_PATHS' => header_paths,
      'FRAMEWORK_SEARCH_PATHS' => "\"#{root}\"",
      'LIBRARY_SEARCH_PATHS' => "\"#{root}\""
    }
  end

  # 4. WatchfaceSDK 子库 (依赖 Zip 和 SSZipArchive)
  s.subspec 'WatchfaceSDK' do |wf|
    wf.source_files = [
      'Vendor/WatchfaceSDK/WatchfaceSDK/Classes/Watchface/**/*',
      'Vendor/WatchfaceSDK/WatchfaceSDK/Classes/OTA/**/*'
    ]
    wf.resources = ['Vendor/WatchfaceSDK/WatchfaceSDK/Assets/*']
    wf.vendored_frameworks = [
      'Vendor/WatchfaceSDK/WatchfaceSDK/SFDialPlateSDK.framework',
      'Vendor/WatchfaceSDK/WatchfaceSDK/eZIPSDK.framework',
      'Vendor/WatchfaceSDK/WatchfaceSDK/SifliOTAManagerSDK.framework',
      'Vendor/WatchfaceSDK/WatchfaceSDK/VideoWatchfaceSDK.framework'
    ]
    wf.frameworks = 'AudioToolbox', 'CoreMedia', 'VideoToolbox', 'AVFoundation'
    wf.libraries = 'bz2', 'z', 'c++'
    # 关键：WatchfaceSDK 依赖 Zip 和 SSZipArchive 子库
    wf.dependency 'blesdk_ios/Zip'
    wf.dependency 'blesdk_ios/SSZipArchive'
  end

  # 5. AiSDK 子库 (依赖 HwBluetoothSDK 和 WatchfaceSDK)
  s.subspec 'AiSDK' do |ai|
    ai.source_files = 'Vendor/AiSDK/AiSDK/Classes/**/*'
    ai.public_header_files = 'Vendor/AiSDK/AiSDK/Classes/**/*.h'
    ai.resource_bundles = {
      'AiSDK' => ['Vendor/AiSDK/AiSDK/Assets/*.png']
    }
    ai.vendored_frameworks = 'Vendor/AiSDK/NativeLib.xcframework', 'Vendor/AiSDK/JLBmpConvertKit.xcframework'
    
    # 关键：AiSDK 依赖其他子库
    ai.dependency 'AFNetworking', '~> 4.0.1'
    ai.dependency 'blesdk_ios/HwBluetoothSDK'
    ai.dependency 'blesdk_ios/WatchfaceSDK'
    # 由于 WatchfaceSDK 已经依赖了 Zip 和 SSZipArchive，这里不需要重复依赖
  end

  # 6. 设置默认子库为 AiSDK
  s.default_subspecs = ['AiSDK']

  # 7. 全局编译配置
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES'
  }
  s.static_framework = true
end
