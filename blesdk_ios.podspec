Pod::Spec.new do |s|
  s.name             = 'blesdk_ios'
  s.version          = '1.0.0'
  s.summary          = 'blesdk_ios - Aggregate BLE SDK'
  s.description      = 'Aggregation of all Huawo BLE related SDKs'
  s.homepage         = 'https://github.com/HWdan/blesdk_ios.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sujiang' => 'sujiang@huawo-wear.com' }
  s.source           = { :git => 'https://github.com/HWdan/blesdk_ios.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'

  # 核心：通过 :path 聚合所有本地子模块
  s.dependency 'HwBluetoothSDK', :path => 'Vendor/HwBluetoothSDK'
  s.dependency 'WatchfaceSDK', :path => 'Vendor/WatchfaceSDK'
  s.dependency 'AiSDK', :path => 'Vendor/AiSDK'
  
  # 公开的外部依赖（从 CocoaPods 官方源获取）
  s.dependency 'AFNetworking', '~> 4.0.1'
  s.dependency 'Zip'
  s.dependency 'SSZipArchive'
  s.static_framework = true
end
