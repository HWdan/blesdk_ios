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
  # 1. Zip 子库 (仅保留源码部分，预编译库由 WatchfaceSDK 直接引用)
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
  # 2. SSZipArchive 子库 (仅保留源码部分)
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
  # 3. HwBluetoothSDK 子库 (静态库 + 头文件，保留不变)
  # ============================================================
  s.subspec 'HwBluetoothSDK' do |hw|
    hw.preserve_paths = [
      'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework',
      'Vendor/HwBluetoothSDK/include',
      'Vendor/HwBluetoothSDK/libHwBluetoothSDK.a',
      'Vendor/HwBluetoothSDK/HwBluetoothSDK.framework/Modules/module.modulemap'
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

  # ============================================================
  # 4. WatchfaceSDK 子库 (关键修改：预编译 framework 全部 vendored)
  # ============================================================
  s.subspec 'WatchfaceSDK' do |wf|
    # 源码部分
    wf.source_files = [
      'Vendor/WatchfaceSDK/WatchfaceSDK/Classes/Watchface/**/*',
      'Vendor/WatchfaceSDK/WatchfaceSDK/Classes/OTA/**/*'
    ]
    wf.resources = ['Vendor/WatchfaceSDK/WatchfaceSDK/Assets/*']
    
    # 【核心修改】所有预编译的 framework 全部列为 vendored_frameworks
    wf.vendored_frameworks = [
      'Vendor/WatchfaceSDK/WatchfaceSDK/SFDialPlateSDK.framework',
      'Vendor/WatchfaceSDK/WatchfaceSDK/eZIPSDK.framework',
      'Vendor/WatchfaceSDK/WatchfaceSDK/SifliOTAManagerSDK.framework',
      'Vendor/WatchfaceSDK/WatchfaceSDK/VideoWatchfaceSDK.framework'
      # 注意：如果 Zip 或 SSZipArchive 是以 .framework 形式存在于 Vendor 中，也应在此列出
    ]
    
    wf.frameworks = 'AudioToolbox', 'CoreMedia', 'VideoToolbox', 'AVFoundation'
    wf.libraries = 'bz2', 'z', 'c++'
    
    # 【关键修改】移除对内部 Zip/SSZipArchive 子库的依赖，因为它们不再以源码方式集成
    # wf.dependency 'blesdk_ios/Zip'
    # wf.dependency 'blesdk_ios/SSZipArchive'
  end

  # ============================================================
  # 5. AiSDK 子库 (依赖关系调整)
  # ============================================================
  s.subspec 'AiSDK' do |ai|
    ai.source_files = 'Vendor/AiSDK/AiSDK/Classes/**/*'
    ai.public_header_files = 'Vendor/AiSDK/AiSDK/Classes/**/*.h'
    ai.resource_bundles = {
      'AiSDK' => ['Vendor/AiSDK/AiSDK/Assets/*.png']
    }
    # AiSDK 自己的预编译库
    ai.vendored_frameworks = 'Vendor/AiSDK/NativeLib.xcframework', 'Vendor/AiSDK/JLBmpConvertKit.xcframework'
    
    # 依赖关系
    ai.dependency 'AFNetworking', '~> 4.0.1'
    # 【关键修改】AiSDK 需要依赖 WatchfaceSDK 子库，以确保其预编译 framework 能被正确链接
    ai.dependency 'blesdk_ios/WatchfaceSDK'
    # 【关键修改】移除对 HwBluetoothSDK 的直接依赖，因为它是通过 vendored_libraries 集成的
    # ai.dependency 'blesdk_ios/HwBluetoothSDK'
    # 【关键修改】移除对 SSZipArchive 的直接依赖，因为其预编译版本已由 WatchfaceSDK 处理
    # ai.dependency 'blesdk_ios/SSZipArchive'
  end

  # ============================================================
  # 6. 默认包含 AiSDK (它会自动引入 WatchfaceSDK)
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
