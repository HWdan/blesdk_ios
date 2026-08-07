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
  # 1. 所有源文件直接包含
  # ============================================================
  s.source_files = [
    'Vendor/Zip/Zip/*.{swift,h}',
    'Vendor/Zip/Zip/minizip/*.{c,h}',
    'Vendor/Zip/Zip/minizip/include/*.{h}',
    'Vendor/SSZipArchive/SSZipArchive/*.{m,h}',
    'Vendor/SSZipArchive/SSZipArchive/include/*.{m,h}',
    'Vendor/SSZipArchive/SSZipArchive/minizip/*.{c,h}',
    'Vendor/WatchfaceSDK/WatchfaceSDK/Classes/Watchface/**/*',
    'Vendor/WatchfaceSDK/WatchfaceSDK/Classes/OTA/**/*',
    'Vendor/AiSDK/AiSDK/Classes/**/*'
  ]

  # ============================================================
  # 2. 公开头文件
  # ============================================================
  s.public_header_files = [
    'Vendor/Zip/Zip/*.h',
    'Vendor/SSZipArchive/SSZipArchive/*.h',
    'Vendor/AiSDK/AiSDK/Classes/**/*.h'
  ]

  # ============================================================
  # 3. 资源文件
  # ============================================================
  s.resource_bundles = {
    'AiSDK' => ['Vendor/AiSDK/AiSDK/Assets/*.png'],
    'WatchfaceSDK' => ['Vendor/WatchfaceSDK/WatchfaceSDK/Assets/*']
  }

  # ============================================================
  # 4. Vendored Frameworks
  # ============================================================
  s.vendored_frameworks = [
    'Vendor/WatchfaceSDK/WatchfaceSDK/SFDialPlateSDK.framework',
    'Vendor/WatchfaceSDK/WatchfaceSDK/eZIPSDK.framework',
    'Vendor/WatchfaceSDK/WatchfaceSDK/SifliOTAManagerSDK.framework',
    'Vendor/WatchfaceSDK/WatchfaceSDK/VideoWatchfaceSDK.framework',
    'Vendor/AiSDK/NativeLib.xcframework',
    'Vendor/AiSDK/JLBmpConvertKit.xcframework'
  ]

  # ============================================================
  # 5. Vendored Libraries
  # ============================================================
  s.vendored_libraries = 'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a'

  # ============================================================
  # 6. 系统框架和库
  # ============================================================
  s.frameworks = [
    'CoreBluetooth', 'Foundation', 'UIKit',
    'AudioToolbox', 'CoreMedia', 'VideoToolbox', 'AVFoundation',
    'Security'
  ]
  s.libraries = 'z', 'c++', 'iconv', 'bz2'

  # ============================================================
  # 7. 外部依赖
  # ============================================================
  s.dependency 'AFNetworking', '~> 4.0.1'

  # ============================================================
  # 8. 编译配置（已修复路径）
  # ============================================================
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/Vendor/HwBluetoothSDK/include" "${PODS_TARGET_SRCROOT}/Vendor/HwBluetoothSDK/include/HwBluetoothSDK" "${PODS_TARGET_SRCROOT}/Vendor/HwBluetoothSDK/HwBluetoothSDK.framework/Headers"',
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/Vendor/HwBluetoothSDK"',
    'LIBRARY_SEARCH_PATHS' => '$(inherited) "${PODS_TARGET_SRCROOT}/Vendor/HwBluetoothSDK"',
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Vendor/Zip/Zip/minizip/** $(PODS_TARGET_SRCROOT)/Vendor/Zip/Zip/minizip/**',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) HAVE_INTTYPES_H HAVE_PKCRYPT HAVE_STDINT_H HAVE_WZAES HAVE_ZLIB'
  }

  # ============================================================
  # 9. 保留路径（已补全）
  # ============================================================
  s.preserve_paths = [
    'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework',
    'Vendor/HwBluetoothSDK/include',
    'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a',
    'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework/Modules/module.modulemap',
    'Vendor/Zip/Zip/minizip/module/module.modulemap',
    'Vendor/Zip/Zip/minizip/include/*'
  ]

  s.static_framework = true
end
