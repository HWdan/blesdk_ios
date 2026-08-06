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

  # --- 定义一个名为 'AiSDK' 的子库 ---
  s.subspec 'AiSDK' do |ai|
    # 指向 Vendor 目录下的 AiSDK 源码
    ai.source_files = 'Vendor/AiSDK/AiSDK/Classes/**/*'
    ai.public_header_files = 'Vendor/AiSDK/AiSDK/Classes/**/*.h'
    ai.resource_bundles = {
      'AiSDK' => ['Vendor/AiSDK/AiSDK/Assets/*.png']
    }
    
    # 保留 AiSDK 的所有原始依赖
    ai.dependency 'AFNetworking', '~> 4.0.1'
    ai.dependency 'HwBluetoothSDK'
    ai.dependency 'WatchfaceSDK'
    ai.dependency 'SSZipArchive'
    
    # 保留 AiSDK 的 vendored frameworks
    ai.vendored_frameworks = 'Vendor/AiSDK/NativeLib.xcframework', 'Vendor/AiSDK/JLBmpConvertKit.xcframework'
  end

  # --- 让主库默认包含 AiSDK 子库 ---
  s.default_subspecs = ['AiSDK']

  # 编译配置保持不变
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES'
  }

  s.static_framework = true
end
