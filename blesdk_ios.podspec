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
  # 1. HwBluetoothSDK 子库
  # ============================================================
  s.subspec 'HwBluetoothSDK' do |hw|
    # 【修复】合并 preserve_paths，避免覆盖
    hw.preserve_paths = [
      'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework',
      'Vendor/HwBluetoothSDK/include',
      'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a',
      'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework/Modules/module.modulemap'
    ]
    hw.vendored_libraries = 'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a'
    hw.frameworks = 'CoreBluetooth', 'Foundation', 'UIKit'
    hw.libraries = 'z', 'c++'
    
    # 建议将路径改为 PODS_TARGET_SRCROOT，更可靠
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

  # ============================================================
  # 2. WatchfaceSDK 子库（依赖从官方源获取）
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
    
    # 从官方源获取
    wf.dependency 'Zip'
    wf.dependency 'SSZipArchive'
  end

  # ============================================================
  # 3. AiSDK 子库
  # ============================================================
  s.subspec 'AiSDK' do |ai|
    ai.source_files = 'Vendor/AiSDK/AiSDK/Classes/**/*'
    ai.public_header_files = 'Vendor/AiSDK/AiSDK/Classes/**/*.h'
    ai.resource_bundles = {
      'AiSDK' => ['Vendor/AiSDK/AiSDK/Assets/*.png']
    }
    ai.vendored_frameworks = 'Vendor/AiSDK/NativeLib.xcframework', 'Vendor/AiSDK/JLBmpConvertKit.xcframework'
    
    ai.dependency 'AFNetworking', '~> 4.0.1'
    ai.dependency 'blesdk_ios/HwBluetoothSDK'
    ai.dependency 'blesdk_ios/WatchfaceSDK'
  end

  # ============================================================
  # 4. 默认包含 AiSDK
  # ============================================================
  s.default_subspecs = ['AiSDK']

  # ============================================================
  # 5. 全局编译配置
  # ============================================================
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES'
  }

  s.static_framework = true
end
