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

  # ============================================================
  # 1. Zip 子库 (来自 Zip.podspec)
  # ============================================================
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

  # ============================================================
  # 2. SSZipArchive 子库 (来自 SSZipArchive.podspec)
  # ============================================================
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

  # ============================================================
  # 3. HwBluetoothSDK 子库 (来自 HwBluetoothSDK.podspec)
  # ============================================================
  s.subspec 'HwBluetoothSDK' do |hw|
    hw.preserve_paths = 'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework', 'Vendor/HwBluetoothSDK/include', 'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a'
    hw.vendored_libraries = 'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a'
    hw.module_map = 'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework/Modules/module.modulemap'
    hw.frameworks = 'CoreBluetooth', 'Foundation', 'UIKit'
    hw.libraries = 'z', 'c++'
    
    root = '${PODS_ROOT}/../Vendor/HwBluetoothSDK'
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

  # ============================================================
  # 4. WatchfaceSDK 子库 (来自 WatchfaceSDK.podspec)
  # ============================================================
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
    wf.dependency 'blesdk_ios/Zip'          # 依赖内部的 Zip 子库
    wf.dependency 'blesdk_ios/SSZipArchive' # 依赖内部的 SSZipArchive 子库
  end

  # ============================================================
  # 5. AiSDK 子库 (来自 AiSDK.podspec)
  # ============================================================
  s.subspec 'AiSDK' do |ai|
    ai.source_files = 'Vendor/AiSDK/AiSDK/Classes/**/*'
    ai.public_header_files = 'Vendor/AiSDK/AiSDK/Classes/**/*.h'
    ai.resource_bundles = {
      'AiSDK' => ['Vendor/AiSDK/AiSDK/Assets/*.png']
    }
    ai.vendored_frameworks = 'Vendor/AiSDK/NativeLib.xcframework', 'Vendor/AiSDK/JLBmpConvertKit.xcframework'
    
    # 依赖关系：指向内部子库
    ai.dependency 'AFNetworking', '~> 4.0.1'        # 公开库
    ai.dependency 'blesdk_ios/HwBluetoothSDK'       # 内部子库
    ai.dependency 'blesdk_ios/WatchfaceSDK'         # 内部子库
    ai.dependency 'blesdk_ios/SSZipArchive'         # 内部子库
  end

  # ============================================================
  # 6. 默认包含 AiSDK（它会自动引入所有依赖）
  # ============================================================
  s.default_subspecs = ['AiSDK']

  # ============================================================
  # 7. 全局编译配置
  # ============================================================
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES'
  }

  s.static_framework = true
end
